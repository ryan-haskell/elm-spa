module Application exposing
    ( Application
    , Bundle
    , Config
    , Context
    , Program
    , Update
    , bundle
    , create
    , init
    , keep
    , start
    , update
    , usingLayout
    )

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div)
import Html.Attributes as Attr
import Internals.Context as Context exposing (Context)
import Internals.Page as Page exposing (Page)
import Internals.Transitionable as Transitionable exposing (Transitionable)
import Process
import Task
import Url exposing (Url)


type Application flags route contextModel contextMsg model msg appElement element
    = Application
        { adapters : Adapters appElement element contextMsg msg
        , config : Config flags route contextModel contextMsg model msg appElement element
        }


type alias Program flags contextModel contextMsg model msg =
    Platform.Program flags (Model flags contextModel model) (Msg contextMsg msg)


type alias Adapters appElement element contextMsg msg =
    { toLayout : appElement -> Html (Msg contextMsg msg)
    , fromHtml : Html (Msg contextMsg msg) -> appElement
    , map : (msg -> Msg contextMsg msg) -> element -> Html (Msg contextMsg msg)
    }


type alias LayoutContext route flags msg =
    { navigateTo : route -> Cmd msg
    , route : route
    , flags : flags
    }


type alias Config flags route contextModel contextMsg model msg appElement element =
    { layout :
        { init :
            LayoutContext route flags (Msg contextMsg msg)
            -> ( contextModel, Cmd contextMsg, Cmd (Msg contextMsg msg) )
        , update :
            LayoutContext route flags (Msg contextMsg msg)
            -> contextMsg
            -> contextModel
            -> ( contextModel, Cmd contextMsg, Cmd (Msg contextMsg msg) )
        , subscriptions :
            LayoutContext route flags (Msg contextMsg msg)
            -> contextModel
            -> Sub contextMsg
        , view :
            { flags : flags
            , route : route
            , toMsg : contextMsg -> Msg contextMsg msg
            , viewPage : appElement
            }
            -> contextModel
            -> appElement
        }
    , pages :
        { init :
            route
            -> Context flags route contextModel
            -> ( model, Cmd msg, Cmd contextMsg )
        , update :
            msg
            -> model
            -> Context flags route contextModel
            -> ( model, Cmd msg, Cmd contextMsg )
        , bundle :
            model
            -> Context flags route contextModel
            -> TitleViewSubs msg element
        }
    , routing :
        { transition : Float
        , fromUrl : Url -> route
        , toPath : route -> String
        }
    }


type alias Context flags route contextModel =
    Context.Context flags route contextModel


create :
    Config flags route contextModel contextMsg model msg (Html (Msg contextMsg msg)) (Html msg)
    -> Application flags route contextModel contextMsg model msg (Html (Msg contextMsg msg)) (Html msg)
create =
    createWith
        { toLayout = identity
        , fromHtml = identity
        , map = Html.map
        }


usingLayout :
    Adapters appElement element contextMsg msg
    -> Application flags route contextModel contextMsg model msg appElement element
    -> Application flags route contextModel contextMsg model msg appElement element
usingLayout adapters (Application application) =
    Application { application | adapters = adapters }


createWith :
    Adapters appElement element contextMsg msg
    -> Config flags route contextModel contextMsg model msg appElement element
    -> Application flags route contextModel contextMsg model msg appElement element
createWith adapters config =
    Application
        { adapters = adapters
        , config = config
        }


start :
    Application flags route contextModel contextMsg model msg appElement element
    -> Program flags contextModel contextMsg model msg
start (Application { adapters, config }) =
    Browser.application
        { init = initWithConfig config
        , update = updateWithConfig config
        , view = viewWithConfig adapters config
        , subscriptions = subscriptionsWithConfig config
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- ACTUAL STUFF


type alias Model flags contextModel model =
    { key : Nav.Key
    , url : Url
    , flags : flags
    , context : contextModel
    , page : Transitionable model
    }


type Msg contextMsg msg
    = UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | PageLoaded Url
    | ContextMsg contextMsg
    | PageMsg msg


initWithConfig :
    Config flags route contextModel contextMsg model msg appElement element
    -> flags
    -> Url
    -> Nav.Key
    -> ( Model flags contextModel model, Cmd (Msg contextMsg msg) )
initWithConfig config flags url key =
    let
        route =
            config.routing.fromUrl url

        ( contextModel, contextCmd, globalCmd ) =
            config.layout.init
                { navigateTo = navigateTo config url
                , route = route
                , flags = flags
                }

        ( pageModel, pageCmd, pageContextCmd ) =
            config.pages.init
                route
                { route = route
                , flags = flags
                , context = contextModel
                }
    in
    ( { url = url
      , key = key
      , flags = flags
      , context = contextModel
      , page = Transitionable.FirstLoad pageModel
      }
    , Cmd.batch
        [ globalCmd
        , delay config.routing.transition (PageLoaded url)
        , Cmd.map ContextMsg contextCmd
        , Cmd.map ContextMsg pageContextCmd
        , Cmd.map PageMsg pageCmd
        ]
    )


delay : Float -> msg -> Cmd msg
delay ms msg =
    Task.perform (\_ -> msg) (Process.sleep ms)


updateWithConfig :
    Config flags route contextModel contextMsg model msg appElement element
    -> Msg contextMsg msg
    -> Model flags contextModel model
    -> ( Model flags contextModel model, Cmd (Msg contextMsg msg) )
updateWithConfig config msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( { model | page = Transitionable.Loading (Transitionable.unwrap model.page) }
            , delay config.routing.transition (PageLoaded url)
            )

        PageLoaded url ->
            let
                route =
                    config.routing.fromUrl url

                ( pageModel, pageCmd, contextCmd ) =
                    config.pages.init
                        route
                        { route = route
                        , flags = model.flags
                        , context = model.context
                        }
            in
            ( { model | url = url, page = Transitionable.Loaded pageModel }
            , Cmd.batch
                [ Cmd.map PageMsg pageCmd
                , Cmd.map ContextMsg contextCmd
                ]
            )

        ContextMsg msg_ ->
            let
                ( contextModel, contextCmd, globalCmd ) =
                    config.layout.update
                        { navigateTo = navigateTo config model.url
                        , route = config.routing.fromUrl model.url
                        , flags = model.flags
                        }
                        msg_
                        model.context
            in
            ( { model | context = contextModel }
            , Cmd.batch
                [ Cmd.map ContextMsg contextCmd
                , globalCmd
                ]
            )

        PageMsg msg_ ->
            let
                ( pageModel, pageCmd, contextCmd ) =
                    config.pages.update
                        msg_
                        (Transitionable.unwrap model.page)
                        { route = config.routing.fromUrl model.url
                        , flags = model.flags
                        , context = model.context
                        }
            in
            ( { model | page = Transitionable.map (always pageModel) model.page }
            , Cmd.batch
                [ Cmd.map ContextMsg contextCmd
                , Cmd.map PageMsg pageCmd
                ]
            )


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


viewWithConfig :
    Adapters appElement element contextMsg msg
    -> Config flags route contextModel contextMsg model msg appElement element
    -> Model flags contextModel model
    -> Document (Msg contextMsg msg)
viewWithConfig adapters config model =
    let
        transitionProp : Float -> String
        transitionProp ms =
            "opacity " ++ String.fromFloat ms ++ "ms ease-in-out"

        ( context, pageModel ) =
            contextAndPage ( config, model )

        bundle_ : TitleViewSubs msg element
        bundle_ =
            config.pages.bundle pageModel context
    in
    { title = bundle_.title
    , body =
        [ div
            [ Attr.class "app"
            , Attr.style "transition" (transitionProp config.routing.transition)
            , Attr.style "opacity" (Transitionable.layoutOpacity model.page)
            ]
            [ adapters.toLayout <|
                config.layout.view
                    { flags = model.flags
                    , route = config.routing.fromUrl model.url
                    , toMsg = ContextMsg
                    , viewPage =
                        adapters.fromHtml <|
                            div
                                [ Attr.style "transition" (transitionProp config.routing.transition)
                                , Attr.style "opacity" (Transitionable.pageOpacity model.page)
                                ]
                                [ adapters.map PageMsg bundle_.view
                                ]
                    }
                    model.context
            ]
        ]
    }


subscriptionsWithConfig :
    Config flags route contextModel contextMsg model msg appElement element
    -> Model flags contextModel model
    -> Sub (Msg contextMsg msg)
subscriptionsWithConfig config model =
    let
        ( context, pageModel ) =
            contextAndPage ( config, model )

        bundle_ =
            config.pages.bundle pageModel context
    in
    Sub.batch
        [ Sub.map ContextMsg
            (config.layout.subscriptions
                { navigateTo = navigateTo config model.url
                , route = config.routing.fromUrl model.url
                , flags = model.flags
                }
                model.context
            )
        , Sub.map PageMsg bundle_.subscriptions
        ]



-- UTILS


contextAndPage :
    ( Config flags route contextModel contextMsg model msg appElement element, Model flags contextModel model )
    -> ( Context flags route contextModel, model )
contextAndPage ( config, model ) =
    ( { route = config.routing.fromUrl model.url
      , flags = model.flags
      , context = model.context
      }
    , Transitionable.unwrap model.page
    )


navigateTo :
    Config flags route contextModel contextMsg model msg appElement element
    -> Url
    -> route
    -> Cmd (Msg contextMsg msg)
navigateTo config url route =
    Task.succeed (config.routing.toPath route)
        |> Task.map (\path -> { url | path = path })
        |> Task.map Browser.Internal
        |> Task.perform UrlRequested



-- HELPERS


type alias Update flags route contextModel contextMsg appModel appMsg =
    Context flags route contextModel -> ( appModel, Cmd appMsg, Cmd contextMsg )


type alias Bundle flags route contextModel appMsg appElement =
    Context flags route contextModel -> TitleViewSubs appMsg appElement


init :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg element
    }
    -> Update flags route contextModel contextMsg appModel appMsg
init config context =
    Page.init config.page context
        |> mapTruple
            { fromMsg = Page.toMsg config.page
            , fromModel = Page.toModel config.page
            }


update :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg element
    , msg : msg
    , model : model
    }
    -> Update flags route contextModel contextMsg appModel appMsg
update config context =
    Page.update config.page context config.msg config.model
        |> mapTruple
            { fromMsg = Page.toMsg config.page
            , fromModel = Page.toModel config.page
            }


keep :
    appModel
    -> Update flags route contextModel contextMsg appModel appMsg
keep model _ =
    ( model, Cmd.none, Cmd.none )


type alias TitleViewSubs appMsg appElement =
    { title : String
    , view : appElement
    , subscriptions : Sub appMsg
    }


bundle :
    ((msg -> appMsg) -> pageElement -> appElement)
    ->
        { page : Page route flags contextModel contextMsg model msg appModel appMsg pageElement
        , model : model
        }
    -> Bundle flags route contextModel appMsg appElement
bundle toHtml config context =
    { title =
        Page.title
            config.page
            context
            config.model
    , view =
        toHtml (Page.toMsg config.page) <|
            Page.view
                config.page
                context
                config.model
    , subscriptions =
        Sub.map (Page.toMsg config.page) <|
            Page.subscriptions
                config.page
                context
                config.model
    }



-- UTILS


mapTruple :
    { fromMsg : msg -> appMsg
    , fromModel : model -> appModel
    }
    -> ( model, Cmd msg, Cmd contextMsg )
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
mapTruple { fromModel, fromMsg } ( a, b, c ) =
    ( fromModel a
    , Cmd.map fromMsg b
    , c
    )

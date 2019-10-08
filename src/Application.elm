module Application exposing
    ( create
    , Application
    , Config
    , Context
    , init, update
    , Bundle, bundle
    , Messages
    )

{-|

@docs create

@docs Application

@docs Config

@docs Context

@docs init, update

@docs Bundle, bundle

@docs Messages

-}

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div)
import Html.Attributes as Attr
import Internals.Context as Context exposing (Context)
import Internals.Page as Page exposing (Page)
import Process
import Task
import Url exposing (Url)


{-| A type that's provided for type annotations!
-}
type alias Application flags contextModel contextMsg model msg =
    Program flags (Model flags contextModel model) (Msg contextMsg msg)


{-| The way to create an `Html` single page application!
-}
create :
    Config flags route contextModel contextMsg model msg
    -> Application flags contextModel contextMsg model msg
create config =
    Browser.application
        { init = initWithConfig config
        , update = updateWithConfig config
        , view = viewWithConfig config
        , subscriptions = subscriptionsWithConfig config
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }


type alias LayoutContext route flags msg =
    { messages : Messages route msg
    , route : route
    , flags : flags
    }


{-| Provide some high-level information for your application.
-}
type alias Config flags route contextModel contextMsg model msg =
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
            route
            -> contextModel
            -> Sub contextMsg
        , view :
            { route : route
            , toMsg : contextMsg -> Msg contextMsg msg
            , viewPage : Html (Msg contextMsg msg)
            }
            -> contextModel
            -> Html (Msg contextMsg msg)
        }
    , pages :
        { init :
            Context flags route contextModel
            -> ( model, Cmd msg, Cmd contextMsg )
        , update :
            Context flags route contextModel
            -> msg
            -> model
            -> ( model, Cmd msg, Cmd contextMsg )
        , bundle :
            Context flags route contextModel
            -> model
            -> Bundle msg
        }
    , routing :
        { transition : Float
        , fromUrl : Url -> route
        , toPath : route -> String
        }
    }


{-| The nformation about the route, flags, or global app state.
-}
type alias Context flags route contextModel =
    Context.Context flags route contextModel



-- ACTUAl STUFF


type alias Model flags contextModel model =
    { key : Nav.Key
    , url : Url
    , flags : flags
    , context : contextModel
    , page : Loadable model
    }


type Loadable a
    = FirstLoad a
    | Loading a
    | Loaded a


isFirstLoad : Loadable a -> Bool
isFirstLoad loadable =
    case loadable of
        FirstLoad _ ->
            True

        _ ->
            False


unwrap : Loadable a -> a
unwrap loadable =
    case loadable of
        FirstLoad a ->
            a

        Loading a ->
            a

        Loaded a ->
            a


map : (a -> b) -> Loadable a -> Loadable b
map fn loadable =
    case loadable of
        FirstLoad a ->
            FirstLoad (fn a)

        Loading a ->
            Loading (fn a)

        Loaded a ->
            Loaded (fn a)


type Msg contextMsg msg
    = UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | PageLoaded Url
    | ContextMsg contextMsg
    | PageMsg msg


{-| These are the messages that your top-level can send to the application.

For now, the only message is `navigateTo`, which navigates to the provided route!

    case msg of
        SignIn (Ok user) ->
            ( { model | user = Just user }
            , Cmd.none
            , navigateTo Route.Homepage
            )

-}
type alias Messages route msg =
    { navigateTo : route -> Cmd msg
    }


initWithConfig :
    Config flags route contextModel contextMsg model msg
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
                { messages = { navigateTo = navigateTo config url }
                , route = route
                , flags = flags
                }

        ( pageModel, pageCmd, pageContextCmd ) =
            config.pages.init
                { route = route
                , flags = flags
                , context = contextModel
                }
    in
    ( { url = url
      , key = key
      , flags = flags
      , context = contextModel
      , page = FirstLoad pageModel
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
    Config flags route contextModel contextMsg model msg
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
            ( { model | page = Loading (unwrap model.page) }
            , delay config.routing.transition (PageLoaded url)
            )

        PageLoaded url ->
            let
                ( pageModel, pageCmd, contextCmd ) =
                    config.pages.init
                        { route = config.routing.fromUrl url
                        , flags = model.flags
                        , context = model.context
                        }
            in
            ( { model | url = url, page = Loaded pageModel }
            , Cmd.batch
                [ Cmd.map PageMsg pageCmd
                , Cmd.map ContextMsg contextCmd
                ]
            )

        ContextMsg msg_ ->
            let
                ( contextModel, contextCmd, globalCmd ) =
                    config.layout.update
                        { messages = { navigateTo = navigateTo config model.url }
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
                        { route = config.routing.fromUrl model.url
                        , flags = model.flags
                        , context = model.context
                        }
                        msg_
                        (unwrap model.page)
            in
            ( { model | page = map (always pageModel) model.page }
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
    Config flags route contextModel contextMsg model msg
    -> Model flags contextModel model
    -> Document (Msg contextMsg msg)
viewWithConfig config model =
    let
        transitionProp : Float -> String
        transitionProp ms =
            "opacity " ++ String.fromFloat ms ++ "ms ease-in-out"

        layoutOpacity : Loadable a -> String
        layoutOpacity loadable =
            case loadable of
                FirstLoad _ ->
                    "0"

                Loading _ ->
                    "1"

                Loaded _ ->
                    "1"

        pageOpacity : Loadable a -> String
        pageOpacity loadable =
            case loadable of
                FirstLoad _ ->
                    "0"

                Loading _ ->
                    "0"

                Loaded _ ->
                    "1"

        ( context, pageModel ) =
            contextAndPage ( config, model )
    in
    { title = config.pages.bundle context pageModel |> .title
    , body =
        [ div
            [ Attr.class "app"
            , Attr.style "transition" (transitionProp config.routing.transition)
            , Attr.style "opacity" (layoutOpacity model.page)
            ]
            [ config.layout.view
                { route = config.routing.fromUrl model.url
                , toMsg = ContextMsg
                , viewPage =
                    div
                        [ Attr.style "transition" (transitionProp config.routing.transition)
                        , Attr.style "opacity" (pageOpacity model.page)
                        ]
                        [ Html.map PageMsg
                            (config.pages.bundle context pageModel |> .view)
                        ]
                }
                model.context
            ]
        ]
    }


subscriptionsWithConfig :
    Config flags route contextModel contextMsg model msg
    -> Model flags contextModel model
    -> Sub (Msg contextMsg msg)
subscriptionsWithConfig config model =
    let
        ( context, pageModel ) =
            contextAndPage ( config, model )
    in
    Sub.batch
        [ Sub.map ContextMsg (config.layout.subscriptions (config.routing.fromUrl model.url) model.context)
        , Sub.map PageMsg (config.pages.bundle context pageModel |> .subscriptions)
        ]



-- UTILS


contextAndPage :
    ( Config flags route contextModel contextMsg model msg, Model flags contextModel model )
    -> ( Context flags route contextModel, model )
contextAndPage ( config, model ) =
    ( { route = config.routing.fromUrl model.url
      , flags = model.flags
      , context = model.context
      }
    , unwrap model.page
    )


navigateTo :
    Config flags route contextModel contextMsg model msg
    -> Url
    -> route
    -> Cmd (Msg contextMsg msg)
navigateTo config url route =
    Task.succeed (config.routing.toPath route)
        |> Task.map (\path -> { url | path = path })
        |> Task.map Browser.Internal
        |> Task.perform UrlRequested



-- HELPERS


{-| Used to help wire up the top-level `init` function.

    -- ...
    case context.route of
        Route.Homepage ->
            Application.init
                { page = pages.homepage
                , context = context
                }
    -- ...

-}
init :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , context : Context flags route contextModel
    }
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
init config =
    Page.init config.page config.context
        |> mapTruple
            { fromMsg = Page.toMsg config.page
            , fromModel = Page.toModel config.page
            }


{-| Used to help wire up the top-level `update` function.

    -- ...
    case ( appModel, appMsg ) of
        ( HomepageModel model, HomepageMsg msg ) ->
            Application.update
                { page = pages.homepage
                , msg = msg
                , model = model
                , context = context
                }
    -- ...

-}
update :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , msg : msg
    , model : model
    , context : Context flags route contextModel
    }
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
update config =
    Page.update config.page config.context config.msg config.model
        |> mapTruple
            { fromMsg = Page.toMsg config.page
            , fromModel = Page.toModel config.page
            }


{-| A bundle of `view`, `subscriptions`, and `title`, to eliminate the need for three separate functions for each at the top-level.
-}
type alias Bundle appMsg =
    { title : String
    , view : Html appMsg
    , subscriptions : Sub appMsg
    }


{-| Used to help wire up the top-level `bundle` function.

    -- ...
    case appModel of
        HomepageModel model ->
            Application.bundle
                { page = pages.homepage
                , model = model
                , context = context
                }
    -- ...

-}
bundle :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , model : model
    , context : Context flags route contextModel
    }
    -> Bundle appMsg
bundle config =
    { title =
        Page.title
            config.page
            config.context
            config.model
    , view =
        Html.map (Page.toMsg config.page) <|
            Page.view
                config.page
                config.context
                config.model
    , subscriptions =
        Sub.map (Page.toMsg config.page) <|
            Page.subscriptions
                config.page
                config.context
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

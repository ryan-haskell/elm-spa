module Application exposing
    ( Application
    , create
    , Messages
    )

{-| A package for building single page apps with Elm!


# Application

@docs Application


# Creating applications

@docs create


# Navigating all smooth-like

@docs Messages

-}

import Application.Page exposing (Context)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div)
import Html.Attributes as Attr
import Process
import Task
import Url exposing (Url)


{-| A type that's provided for type annotations!

Instead of `Program Flags Model Msg`, you can use this type to annotate your main method:

    main : Application Flags Context.Model Context.Msg App.Model App.Msg
    main =
        Application.create { ... }

-}
type alias Application flags contextModel contextMsg model msg =
    Program flags (Model flags contextModel model) (Msg contextMsg msg)


type alias Config flags route contextModel contextMsg model msg =
    { context :
        { init :
            route
            -> flags
            -> ( contextModel, Cmd contextMsg )
        , update :
            Messages route (Msg contextMsg msg)
            -> route
            -> contextMsg
            -> contextModel
            -> ( contextModel, Cmd contextMsg, Cmd (Msg contextMsg msg) )
        , subscriptions :
            route
            -> contextModel
            -> Sub contextMsg
        , view :
            { route : route
            , context : contextModel
            , toMsg : contextMsg -> Msg contextMsg msg
            , viewPage : Html (Msg contextMsg msg)
            }
            -> Html (Msg contextMsg msg)
        }
    , page :
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
            -> Application.Page.Bundle msg
        }
    , route :
        { fromUrl : Url -> route
        , toPath : route -> String
        }
    , transition : Float
    }


{-| The way to create an `Application`!

Provide this function with a configuration, and it will bundle things up for you.

Here's an example (from the `examples/basic` folder of this repo):

    main : Application Flags Context.Model Context.Msg App.Model App.Msg
    main =
        Application.create
            { transition = 200
            , context =
                { init = Context.init
                , update = Context.update
                , view = Context.view
                , subscriptions = Context.subscriptions
                }
            , page =
                { init = App.init
                , update = App.update
                , bundle = App.view
                }
            , route =
                { fromUrl = Route.fromUrl
                , toPath = Route.toPath
                }
            }

-}
create :
    Config flags route contextModel contextMsg model msg
    -> Application flags contextModel contextMsg model msg
create config =
    Browser.application
        { init = init config
        , update = update config
        , view = view config
        , subscriptions = subscriptions config
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }


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


type alias Messages route msg =
    { navigateTo : route -> Cmd msg
    }


init :
    Config flags route contextModel contextMsg model msg
    -> flags
    -> Url
    -> Nav.Key
    -> ( Model flags contextModel model, Cmd (Msg contextMsg msg) )
init config flags url key =
    let
        route =
            config.route.fromUrl url

        ( contextModel, contextCmd ) =
            config.context.init route flags

        ( pageModel, pageCmd, pageContextCmd ) =
            config.page.init
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
        [ delay config.transition (PageLoaded url)
        , Cmd.map ContextMsg contextCmd
        , Cmd.map ContextMsg pageContextCmd
        , Cmd.map PageMsg pageCmd
        ]
    )


delay : Float -> msg -> Cmd msg
delay ms msg =
    Task.perform (\_ -> msg) (Process.sleep ms)


update :
    Config flags route contextModel contextMsg model msg
    -> Msg contextMsg msg
    -> Model flags contextModel model
    -> ( Model flags contextModel model, Cmd (Msg contextMsg msg) )
update config msg model =
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
            , delay config.transition (PageLoaded url)
            )

        PageLoaded url ->
            let
                ( pageModel, pageCmd, contextCmd ) =
                    config.page.init
                        { route = config.route.fromUrl url
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
                    config.context.update
                        { navigateTo = navigateTo config model.url
                        }
                        (config.route.fromUrl model.url)
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
                    config.page.update
                        { route = config.route.fromUrl model.url
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


view :
    Config flags route contextModel contextMsg model msg
    -> Model flags contextModel model
    -> Document (Msg contextMsg msg)
view config model =
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
    { title = config.page.bundle context pageModel |> .title
    , body =
        [ div
            [ Attr.class "app"
            , Attr.style "transition" (transitionProp config.transition)
            , Attr.style "opacity" (layoutOpacity model.page)
            ]
            [ config.context.view
                { route = config.route.fromUrl model.url
                , toMsg = ContextMsg
                , context = model.context
                , viewPage =
                    div
                        [ Attr.style "transition" (transitionProp config.transition)
                        , Attr.style "opacity" (pageOpacity model.page)
                        ]
                        [ Html.map PageMsg
                            (config.page.bundle context pageModel |> .view)
                        ]
                }
            ]
        ]
    }


subscriptions :
    Config flags route contextModel contextMsg model msg
    -> Model flags contextModel model
    -> Sub (Msg contextMsg msg)
subscriptions config model =
    let
        ( context, pageModel ) =
            contextAndPage ( config, model )
    in
    Sub.batch
        [ Sub.map ContextMsg (config.context.subscriptions (config.route.fromUrl model.url) model.context)
        , Sub.map PageMsg (config.page.bundle context pageModel |> .subscriptions)
        ]



-- UTILS


contextAndPage :
    ( Config flags route contextModel contextMsg model msg, Model flags contextModel model )
    -> ( Application.Page.Context flags route contextModel, model )
contextAndPage ( config, model ) =
    ( { route = config.route.fromUrl model.url
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
    Task.succeed (config.route.toPath route)
        |> Task.map (\path -> { url | path = path })
        |> Task.map Browser.Internal
        |> Task.perform UrlRequested

module Application exposing
    ( Application, create
    , Transition, fade, none
    )

{-|


## Applications

@docs Application, create


## Layouts

@docs Layout


## Transitions

@docs Transition, fade, none

-}

import Application.Page as Page
import Application.Route as Route
import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Transition as Transition
import Internals.Transitionable as Transitionable exposing (Transitionable)
import Internals.Utils as Utils
import Task
import Url exposing (Url)
import Url.Parser as Parser



-- APPLICATION


type alias Application flags globalModel globalMsg layoutModel layoutMsg =
    Platform.Program flags (Model flags globalModel layoutModel) (Msg globalMsg layoutMsg)


create :
    { routing :
        { routes : Routes route
        , toPath : route -> String
        , notFound : route
        }
    , global :
        { init :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> flags
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , update :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> globalMsg
            -> globalModel
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , subscriptions : globalModel -> Sub globalMsg
        }
    , layout :
        { transition : Transition (Html (Msg globalMsg layoutMsg))
        , view :
            { page : Html (Msg globalMsg layoutMsg)
            , global : globalModel
            }
            -> Html (Msg globalMsg layoutMsg)
        }
    , pages :
        { init : route -> Page.Init layoutModel layoutMsg globalModel globalMsg
        , update : layoutMsg -> layoutModel -> Page.Update layoutModel layoutMsg globalModel globalMsg
        , bundle : layoutModel -> Page.Bundle layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg)
        }
    }
    -> Application flags globalModel globalMsg layoutModel layoutMsg
create config =
    Browser.application
        { init =
            init
                { init =
                    { global = config.global.init
                    , pages = config.pages.init
                    }
                , routing =
                    { fromUrl = fromUrl config.routing
                    , toPath = config.routing.toPath
                    }
                , speed = Transition.speed config.layout.transition
                }
        , update =
            update
                { routing =
                    { fromUrl = fromUrl config.routing
                    , toPath = config.routing.toPath
                    }
                , init = config.pages.init
                , update =
                    { global = config.global.update
                    , pages = config.pages.update
                    }
                , speed = Transition.speed config.layout.transition
                }
        , subscriptions =
            subscriptions
                { bundle = config.pages.bundle
                }
        , view =
            view
                { bundle = config.pages.bundle
                , layout = config.layout.view
                , transition = Transition.strategy config.layout.transition
                }
        , onUrlChange = Url
        , onUrlRequest = Link
        }


private :
    { fromGlobalMsg : globalMsg -> Msg globalMsg layoutMsg
    , fromPageMsg : layoutMsg -> Msg globalMsg layoutMsg
    }
private =
    { fromGlobalMsg = Global
    , fromPageMsg = Page
    }



-- ROUTING


type alias Routes route =
    List (Route.Route route)


fromUrl : { a | routes : Routes route, notFound : route } -> Url -> route
fromUrl config =
    Parser.parse (Parser.oneOf config.routes)
        >> Maybe.withDefault config.notFound



-- INIT


type alias Model flags globalModel model =
    { urls :
        { previous : Maybe Url
        , current : Url
        }
    , flags : flags
    , key : Nav.Key
    , global : globalModel
    , page : Transitionable model
    , speed : Int
    }


init :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
        }
    , init :
        { global :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> flags
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , pages : route -> Page.Init layoutModel layoutMsg globalModel globalMsg
        }
    , speed : Int
    }
    -> flags
    -> Url
    -> Nav.Key
    -> ( Model flags globalModel layoutModel, Cmd (Msg globalMsg layoutMsg) )
init config flags url key =
    url
        |> config.routing.fromUrl
        |> (\route ->
                let
                    ( globalModel, globalCmd, cmd ) =
                        config.init.global
                            { navigate = navigate config.routing.toPath url
                            }
                            flags

                    ( pageModel, pageCmd, pageGlobalCmd ) =
                        config.init.pages route globalModel
                in
                ( { flags = flags
                  , urls = { previous = Nothing, current = url }
                  , key = key
                  , global = globalModel
                  , page = Transitionable.Ready pageModel
                  , speed = config.speed
                  }
                , Cmd.batch
                    [ handleJumpLinks url pageCmd
                    , Cmd.map Global globalCmd
                    , Cmd.map Global pageGlobalCmd
                    , Utils.delay config.speed TransitionComplete
                    , cmd
                    ]
                )
           )


handleJumpLinks : Url -> Cmd msg -> Cmd (Msg globalMsg msg)
handleJumpLinks url cmd =
    Cmd.batch
        [ Cmd.map Page cmd
        , scrollToHash ScrollComplete url
        ]


scrollToHash : msg -> Url -> Cmd msg
scrollToHash msg { fragment } =
    let
        scrollTo : String -> Cmd msg
        scrollTo =
            Dom.getElement
                >> Task.andThen (\el -> Dom.setViewport 0 el.element.y)
                >> Task.attempt (\_ -> msg)
    in
    fragment
        |> Maybe.map scrollTo
        |> Maybe.withDefault Cmd.none



-- UPDATE


type Msg globalMsg msg
    = Url Url
    | Link Browser.UrlRequest
    | TransitionTo Url
    | ScrollComplete
    | TransitionComplete
    | Global globalMsg
    | Page msg


update :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
        }
    , init : route -> Page.Init layoutModel layoutMsg globalModel globalMsg
    , update :
        { global :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> globalMsg
            -> globalModel
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , pages :
            layoutMsg
            -> layoutModel
            -> Page.Update layoutModel layoutMsg globalModel globalMsg
        }
    , speed : Int
    }
    -> Msg globalMsg layoutMsg
    -> Model flags globalModel layoutModel
    -> ( Model flags globalModel layoutModel, Cmd (Msg globalMsg layoutMsg) )
update config msg model =
    case msg of
        ScrollComplete ->
            ( model, Cmd.none )

        Link (Browser.Internal url) ->
            if url == model.urls.current && url.fragment == Nothing then
                ( model, Cmd.none )

            else if url.path == model.urls.current.path then
                ( model, Nav.load (Url.toString url) )

            else
                ( if navigatingWithinLayout { old = model.urls.current, new = url } then
                    { model | page = Transitionable.complete model.page }

                  else
                    { model | page = Transitionable.begin model.page }
                , Utils.delay model.speed (TransitionTo url)
                )

        Link (Browser.External url) ->
            ( model
            , Nav.load url
            )

        TransitionTo url ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )

        TransitionComplete ->
            ( { model | page = Transitionable.complete model.page }
            , Cmd.none
            )

        Url url ->
            url
                |> config.routing.fromUrl
                |> (\route -> config.init route model.global)
                |> (\( pageModel, pageCmd, globalCmd ) ->
                        ( { model
                            | urls =
                                { previous = Just model.urls.current
                                , current = url
                                }
                            , page = Transitionable.Complete pageModel
                            , speed = config.speed
                          }
                        , Cmd.batch
                            [ handleJumpLinks url pageCmd
                            , Cmd.map Global globalCmd
                            ]
                        )
                   )

        Global globalMsg ->
            config.update.global
                { navigate = navigate config.routing.toPath model.urls.current
                }
                globalMsg
                model.global
                |> (\( global, globalCmd, cmd ) ->
                        ( { model | global = global }
                        , Cmd.batch
                            [ Cmd.map Global globalCmd
                            , cmd
                            ]
                        )
                   )

        Page pageMsg ->
            config.update.pages pageMsg (Transitionable.unwrap model.page) model.global
                |> (\( page, pageCmd, globalCmd ) ->
                        ( { model | page = Transitionable.Complete page }
                        , Cmd.batch
                            [ Cmd.map Page pageCmd
                            , Cmd.map Global globalCmd
                            ]
                        )
                   )


navigate : (route -> String) -> Url -> route -> Cmd (Msg globalMsg layoutMsg)
navigate toPath url route =
    Utils.send <|
        Link (Browser.Internal { url | path = toPath route })


navigatingWithinLayout : { old : Url, new : Url } -> Bool
navigatingWithinLayout urls =
    let
        firstSegment { path } =
            String.split "/" path |> List.drop 1 |> List.head

        old =
            firstSegment urls.old

        new =
            firstSegment urls.new
    in
    old == new && old /= Nothing



-- SUBSCRIPTIONS


subscriptions :
    { bundle :
        layoutModel
        -> Page.Bundle layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg)
    }
    -> Model flags globalModel layoutModel
    -> Sub (Msg globalMsg layoutMsg)
subscriptions config model =
    (config.bundle
        (Transitionable.unwrap model.page)
        model.global
        private
    ).subscriptions



-- VIEW


view :
    { bundle :
        layoutModel
        -> Page.Bundle layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg)
    , transition : Transition.Strategy (Html (Msg globalMsg layoutMsg))
    , layout :
        { page : Html (Msg globalMsg layoutMsg)
        , global : globalModel
        }
        -> Html (Msg globalMsg layoutMsg)
    }
    -> Model flags globalModel layoutModel
    -> Browser.Document (Msg globalMsg layoutMsg)
view config model =
    let
        fromPage :
            layoutModel
            ->
                { layout :
                    { page : Html (Msg globalMsg layoutMsg)
                    }
                    -> Html (Msg globalMsg layoutMsg)
                , page : Html (Msg globalMsg layoutMsg)
                }
        fromPage layoutModel =
            let
                page : Html (Msg globalMsg layoutMsg)
                page =
                    (config.bundle layoutModel model.global private).view
            in
            { layout =
                \data ->
                    config.layout { page = data.page, global = model.global }
            , page = page
            }
    in
    { title = "elm-app demo"
    , body =
        [ case model.page of
            Transitionable.Ready layoutModel ->
                config.transition.beforeLoad (fromPage layoutModel)

            Transitionable.Transitioning layoutModel ->
                config.transition.leavingPage (fromPage layoutModel)

            Transitionable.Complete layoutModel ->
                config.transition.enteringPage (fromPage layoutModel)
        ]
    }



-- TRANSITIONS


type alias Transition a =
    Transition.Transition a


fade : Int -> Transition (Html msg)
fade =
    Transition.fade


none : Transition a
none =
    Transition.none

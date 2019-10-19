module Application exposing
    ( Application, create
    , Page, Recipe
    , Bundle, keep
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Transition, fade
    , none
    )

{-|

@docs Application, create

@docs Page, Recipe
@docs Bundle, keep

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

@docs PageWithParams, RecipeWithParams

@docs ElementWithParams, elementWithParams

@docs Transition, fade

-}

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Page as Page
import Internals.Transition as Transition exposing (Transitionable)
import Internals.Utils as Utils
import Task
import Url exposing (Url)



-- APPLICATION


type alias Application flags model msg =
    Platform.Program flags (Model flags model) (Msg msg)


create :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
        , transition : Transition (Html msg)
        }
    , layout :
        { view : { page : Html msg } -> Html msg
        }
    , pages :
        { init : route -> ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , bundle : model -> Page.Bundle msg
        }
    }
    -> Application flags model msg
create config =
    let
        transition =
            unwrap config.routing.transition
    in
    Browser.application
        { init =
            init
                { init = config.pages.init
                , fromUrl = config.routing.fromUrl
                , speed = transition.speed
                }
        , update =
            update
                { fromUrl = config.routing.fromUrl
                , init = config.pages.init
                , update = config.pages.update
                , speed = transition.speed
                }
        , subscriptions =
            subscriptions
                { subscriptions = config.pages.bundle >> .subscriptions
                }
        , view =
            view
                { view = config.pages.bundle >> .view
                , layout = config.layout.view
                , transition = transition.strategy transition.speed
                }
        , onUrlChange = Url
        , onUrlRequest = Link
        }



-- INIT


type alias Model flags model =
    { url : Url
    , flags : flags
    , key : Nav.Key
    , page : Transitionable model
    }


init :
    { fromUrl : Url -> route
    , init : route -> ( model, Cmd msg )
    , speed : Int
    }
    -> flags
    -> Url
    -> Nav.Key
    -> ( Model flags model, Cmd (Msg msg) )
init config flags url key =
    url
        |> config.fromUrl
        |> config.init
        |> Tuple.mapBoth
            (\page ->
                { flags = flags
                , url = url
                , key = key
                , page = Transition.Ready page
                }
            )
            (\cmd ->
                Cmd.batch
                    [ handleJumpLinks url cmd
                    , Utils.delay config.speed TransitionComplete
                    ]
            )


handleJumpLinks : Url -> Cmd msg -> Cmd (Msg msg)
handleJumpLinks url cmd =
    Cmd.batch
        [ Cmd.map Page cmd
        , scrollToHash url
        ]


scrollToHash : Url -> Cmd (Msg msg)
scrollToHash { fragment } =
    fragment
        |> Maybe.map scrollTo
        |> Maybe.withDefault Cmd.none


scrollTo : String -> Cmd (Msg msg)
scrollTo =
    Dom.getElement
        >> Task.andThen (\el -> Dom.setViewport 0 el.element.y)
        >> Task.attempt (\_ -> ScrollComplete)



-- UPDATE


type Msg msg
    = Url Url
    | Link Browser.UrlRequest
    | TransitionTo Url
    | ScrollComplete
    | TransitionComplete
    | Page msg


update :
    { fromUrl : Url -> route
    , init : route -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , speed : Int
    }
    -> Msg msg
    -> Model flags model
    -> ( Model flags model, Cmd (Msg msg) )
update config msg model =
    case msg of
        ScrollComplete ->
            ( model, Cmd.none )

        Link (Browser.Internal url) ->
            if url == model.url then
                ( model, Cmd.none )

            else
                ( { model | page = Transition.begin model.page }
                , Utils.delay config.speed (TransitionTo url)
                )

        Link (Browser.External url) ->
            ( model
            , Nav.load url
            )

        TransitionTo url ->
            ( model
            , if url.path == model.url.path then
                Nav.load (Url.toString url)

              else
                Nav.pushUrl model.key (Url.toString url)
            )

        TransitionComplete ->
            ( { model | page = Transition.complete model.page }
            , Cmd.none
            )

        Url url ->
            url
                |> config.fromUrl
                |> config.init
                |> Tuple.mapBoth
                    (\page -> { model | url = url, page = Transition.Complete page })
                    (handleJumpLinks url)

        Page pageMsg ->
            Tuple.mapBoth
                (\page -> { model | page = Transition.Complete page })
                (Cmd.map Page)
                (config.update pageMsg (Transition.unwrap model.page))



-- SUBSCRIPTIONS


subscriptions :
    { subscriptions : model -> Sub msg }
    -> Model flags model
    -> Sub (Msg msg)
subscriptions config model =
    Sub.map Page (config.subscriptions (Transition.unwrap model.page))



-- VIEW


view :
    { view : model -> Html msg
    , transition : Transition.Options (Html msg)
    , layout : { page : Html msg } -> Html msg
    }
    -> Model flags model
    -> Browser.Document (Msg msg)
view config model =
    { title = "elm-app demo"
    , body =
        [ Html.map Page <|
            case model.page of
                Transition.Ready page ->
                    config.transition.beforeLoad
                        { layout = config.layout
                        , page = config.view page
                        }

                Transition.Transitioning page ->
                    config.transition.leavingPage
                        { layout = config.layout
                        , page = config.view page
                        }

                Transition.Complete page ->
                    config.transition.enteringPage
                        { layout = config.layout
                        , page = config.view page
                        }
        ]
    }



-- PAGE API


type alias Page params pageModel pageMsg model msg =
    Page.Page params pageModel pageMsg model msg


type alias Recipe params pageModel pageMsg model msg =
    Page.Recipe params pageModel pageMsg model msg


type alias Bundle msg =
    Page.Bundle msg


keep : model -> ( model, Cmd msg )
keep model =
    ( model, Cmd.none )


type alias Static =
    Page.Static


static :
    Static
    -> Page params () Never model msg
static =
    Page.static


type alias Sandbox pageModel pageMsg params =
    Page.Sandbox pageModel pageMsg params


sandbox :
    Sandbox pageModel pageMsg params
    -> Page params pageModel pageMsg model msg
sandbox =
    Page.sandbox


type alias Element pageModel pageMsg params =
    Page.Element pageModel pageMsg params


element :
    Element pageModel pageMsg params
    -> Page params pageModel pageMsg model msg
element =
    Page.element



-- TRANSITIONS


type Transition view
    = Using (TransitionInfo view)
    | None


type alias TransitionInfo view =
    { speed : Int
    , strategy : Transition.Strategy view
    }


unwrap : Transition a -> TransitionInfo a
unwrap transition =
    case transition of
        Using value ->
            value

        None ->
            { speed = 0
            , strategy = Transition.none
            }


fade : Int -> Transition (Html msg)
fade speed =
    Using
        { speed = speed
        , strategy = Transition.fade
        }


none : Transition a
none =
    None

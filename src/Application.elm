module Application exposing
    ( Application, create
    , Layout
    , Page, Recipe
    , Routes, Init, Bundle, keep
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Glue, Pages, glue
    , Transition, fade, none
    )

{-|


## Applications

@docs Application, create


## Layouts

@docs Layout


## Pages

@docs Page, Recipe

@docs Routes, Init, Bundle, keep

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

@docs Glue, Pages, glue


## Transitions

@docs Transition, fade, none

-}

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Layout as Layout
import Internals.Page as Page
import Internals.Route as Route
import Internals.Transition as Transition
import Internals.Transitionable as Transitionable exposing (Transitionable)
import Internals.Utils as Utils
import Task
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)



-- APPLICATION


type alias Application flags model msg =
    Platform.Program flags (Model flags model) (Msg msg)


create :
    { routing :
        { routes : Routes route
        , notFound : route
        }
    , layout :
        { view : { page : Html msg } -> Html msg
        , transition : Transition (Html msg)
        }
    , pages :
        { init : route -> Init model msg
        , update : msg -> model -> ( model, Cmd msg )
        , bundle : model -> Bundle msg
        }
    }
    -> Application flags model msg
create config =
    Browser.application
        { init =
            init
                { init = config.pages.init
                , fromUrl = fromUrl config.routing
                , speed = Transition.speed config.layout.transition
                }
        , update =
            update
                { fromUrl = fromUrl config.routing
                , init = config.pages.init
                , update = config.pages.update
                , speed = Transition.speed config.layout.transition
                }
        , subscriptions =
            subscriptions
                { subscriptions = config.pages.bundle >> .subscriptions
                }
        , view =
            view
                { view = config.pages.bundle >> .view
                , layout = config.layout
                , transition = Transition.strategy config.layout.transition
                }
        , onUrlChange = Url
        , onUrlRequest = Link
        }



-- ROUTING


type alias Routes route =
    List (Route.Route route)


fromUrl : { routes : Routes route, notFound : route } -> Url -> route
fromUrl config =
    Parser.parse (Parser.oneOf config.routes)
        >> Maybe.withDefault config.notFound



-- INIT


type alias Model flags model =
    { urls :
        { previous : Maybe Url
        , current : Url
        }
    , flags : flags
    , key : Nav.Key
    , page : Transitionable model
    , speed : Int
    }


init :
    { fromUrl : Url -> route
    , init : route -> Init model msg
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
        |> (\( pageModel, pageCmd ) ->
                ( { flags = flags
                  , urls = { previous = Nothing, current = url }
                  , key = key
                  , page = Transitionable.Ready pageModel
                  , speed = config.speed
                  }
                , Cmd.batch
                    [ handleJumpLinks url pageCmd
                    , Utils.delay config.speed TransitionComplete
                    ]
                )
           )


handleJumpLinks : Url -> Cmd msg -> Cmd (Msg msg)
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


type Msg msg
    = Url Url
    | Link Browser.UrlRequest
    | TransitionTo Url
    | ScrollComplete
    | TransitionComplete
    | Page msg


update :
    { fromUrl : Url -> route
    , init : route -> Init model msg
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
                |> config.fromUrl
                |> config.init
                |> (\( pageModel, pageCmd ) ->
                        ( { model
                            | urls =
                                { previous = Just model.urls.current
                                , current = url
                                }
                            , page = Transitionable.Complete pageModel
                            , speed = config.speed
                          }
                        , handleJumpLinks url pageCmd
                        )
                   )

        Page pageMsg ->
            Tuple.mapBoth
                (\page -> { model | page = Transitionable.Complete page })
                (Cmd.map Page)
                (config.update pageMsg (Transitionable.unwrap model.page))


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
    { subscriptions : model -> Sub msg }
    -> Model flags model
    -> Sub (Msg msg)
subscriptions config model =
    Sub.map Page (config.subscriptions (Transitionable.unwrap model.page))



-- VIEW


view :
    { view : model -> Html msg
    , transition : Transition.Strategy (Html msg)
    , layout : Layout msg
    }
    -> Model flags model
    -> Browser.Document (Msg msg)
view config model =
    { title = "elm-app demo"
    , body =
        [ Html.map Page <|
            case model.page of
                Transitionable.Ready page ->
                    config.transition.beforeLoad
                        { layout = config.layout.view
                        , page = config.view page
                        }

                Transitionable.Transitioning page ->
                    config.transition.leavingPage
                        { layout = config.layout.view
                        , page = config.view page
                        }

                Transitionable.Complete page ->
                    config.transition.enteringPage
                        { layout = config.layout.view
                        , page = config.view page
                        }
        ]
    }



-- Layouts


type alias Layout msg =
    Layout.Layout msg



-- PAGE API


type alias Page pageRoute pageModel pageMsg model msg =
    Page.Page pageRoute pageModel pageMsg model msg


type alias Recipe pageRoute pageModel pageMsg model msg =
    Page.Recipe pageRoute pageModel pageMsg model msg


type alias Init model msg =
    Page.Init model msg


type alias Bundle msg =
    Page.Bundle msg


keep : model -> ( model, Cmd msg )
keep model =
    ( model, Cmd.none )


type alias Static =
    Page.Static


static :
    Static
    -> Page pageRoute () Never model msg
static =
    Page.static


type alias Sandbox pageRoute pageModel pageMsg =
    Page.Sandbox pageRoute pageModel pageMsg


sandbox :
    Sandbox pageRoute pageModel pageMsg
    -> Page pageRoute pageModel pageMsg model msg
sandbox =
    Page.sandbox


type alias Element pageRoute pageModel pageMsg =
    Page.Element pageRoute pageModel pageMsg


element :
    Element pageRoute pageModel pageMsg
    -> Page pageRoute pageModel pageMsg model msg
element =
    Page.element


type alias Glue pageRoute layoutModel layoutMsg =
    Page.Glue pageRoute layoutModel layoutMsg


type alias Pages pageRoute layoutModel layoutMsg =
    Page.Pages pageRoute layoutModel layoutMsg


glue :
    Glue pageRoute layoutModel layoutMsg
    -> Page pageRoute layoutModel layoutMsg model msg
glue =
    Page.glue



-- TRANSITIONS


type alias Transition a =
    Transition.Transition a


fade : Int -> Transition (Html msg)
fade =
    Transition.fade


none : Transition a
none =
    Transition.none

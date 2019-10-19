module Application exposing
    ( Application, create
    , Page, Recipe
    , Bundle, keep
    , Static, static
    , Sandbox, sandbox
    , Element, element
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

-}

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Page as Page
import Task
import Url exposing (Url)



-- APPLICATION


type alias Application flags model msg =
    Platform.Program flags (Model flags model) (Msg msg)


create :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
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
    Browser.application
        { init =
            init
                { init = config.pages.init
                , fromUrl = config.routing.fromUrl
                }
        , update =
            update
                { fromUrl = config.routing.fromUrl
                , init = config.pages.init
                , update = config.pages.update
                }
        , subscriptions =
            subscriptions
                { subscriptions = config.pages.bundle >> .subscriptions
                }
        , view =
            view
                { view = config.pages.bundle >> .view
                , layout = config.layout.view
                }
        , onUrlChange = Url
        , onUrlRequest = Link
        }



-- INIT


type alias Model flags model =
    { url : Url
    , flags : flags
    , key : Nav.Key
    , page : model
    }


init :
    { fromUrl : Url -> route
    , init : route -> ( model, Cmd msg )
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
            (\page -> { flags = flags, url = url, key = key, page = page })
            (handleJumpLinks url)


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
    | ScrollComplete
    | Page msg


update :
    { fromUrl : Url -> route
    , init : route -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    }
    -> Msg msg
    -> Model flags model
    -> ( Model flags model, Cmd (Msg msg) )
update config msg model =
    case msg of
        ScrollComplete ->
            ( model, Cmd.none )

        Url url ->
            url
                |> config.fromUrl
                |> config.init
                |> Tuple.mapBoth
                    (\page -> { model | url = url, page = page })
                    (handleJumpLinks url)

        Link (Browser.Internal url) ->
            if url.path == model.url.path then
                ( model
                , Nav.load (Url.toString url)
                )

            else
                ( model
                , Nav.pushUrl model.key (Url.toString url)
                )

        Link (Browser.External url) ->
            ( model
            , Nav.load url
            )

        -- Reload ->
        --     ( model
        --     , Nav.reload
        --     )
        Page pageMsg ->
            Tuple.mapBoth
                (\page -> { model | page = page })
                (Cmd.map Page)
                (config.update pageMsg model.page)



-- SUBSCRIPTIONS


subscriptions :
    { subscriptions : model -> Sub msg }
    -> Model flags model
    -> Sub (Msg msg)
subscriptions config model =
    Sub.map Page (config.subscriptions model.page)



-- VIEW


view :
    { view : model -> Html msg
    , layout : { page : Html msg } -> Html msg
    }
    -> Model flags model
    -> Browser.Document (Msg msg)
view config model =
    { title = "App title"
    , body =
        [ Html.map Page <|
            config.layout
                { page = config.view model.page
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

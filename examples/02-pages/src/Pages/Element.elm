module Pages.Element exposing (Model, Msg, page)

import Browser.Dom exposing (Viewport)
import Browser.Events
import Gen.Params.Element exposing (Params)
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Json.Decode as Json
import Page
import Request
import Shared
import Task
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { window : { width : Int, height : Int }
    , image : WebRequest
    }


type WebRequest
    = NotAsked
    | Success String
    | Failure


init : ( Model, Cmd Msg )
init =
    ( { window = { width = 0, height = 0 }
      , image = NotAsked
      }
    , Browser.Dom.getViewport
        |> Task.perform GotInitialViewport
    )



-- UPDATE


type Msg
    = ResizedWindow Int Int
    | GotInitialViewport Viewport
    | ClickedFetchCat
    | GotCatGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotInitialViewport { viewport } ->
            ( { model
                | window =
                    { width = floor viewport.width
                    , height = floor viewport.height
                    }
              }
            , Cmd.none
            )

        ResizedWindow w h ->
            ( { model | window = { width = w, height = h } }
            , Cmd.none
            )

        ClickedFetchCat ->
            let
                gifDecoder =
                    Json.field "url" Json.string
                        |> Json.map (\url -> "https://cataas.com" ++ url)
            in
            ( model
            , Http.get
                { url = "https://cataas.com/cat?json=true&type=sm"
                , expect = Http.expectJson GotCatGif gifDecoder
                }
            )

        GotCatGif (Ok url) ->
            ( { model | image = Success url }
            , Cmd.none
            )

        GotCatGif (Err _) ->
            ( { model | image = Failure }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize ResizedWindow



-- VIEW


view : Model -> View Msg
view model =
    { title = "Element"
    , body =
        UI.layout
            [ UI.h1 "Element"
            , Html.p [] [ Html.text "An element page can perform side-effects like HTTP requests and subscribe to events from the browser!" ]
            , Html.br [] []
            , Html.h2 [] [ Html.text "Commands" ]
            , Html.p []
                [ Html.button [ Events.onClick ClickedFetchCat ] [ Html.text "Get a cat" ]
                ]
            , case model.image of
                NotAsked ->
                    Html.text ""

                Failure ->
                    Html.text "Something went wrong, please try again."

                Success image ->
                    Html.img [ Attr.src image, Attr.alt "Cat" ] []
            , Html.br [] []
            , Html.h2 [] [ Html.text "Subscriptions" ]
            , Html.p []
                [ Html.strong [] [ Html.text "Window size:" ]
                , Html.text (windowSizeToString model.window)
                ]
            ]
    }


windowSizeToString : { width : Int, height : Int } -> String
windowSizeToString { width, height } =
    "( " ++ String.fromInt width ++ ", " ++ String.fromInt height ++ " )"

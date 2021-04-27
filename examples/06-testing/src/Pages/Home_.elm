module Pages.Home_ exposing (Model, Msg, init, page, update, view)

import Gen.Params.Home_ exposing (Params)
import Html exposing (Html)
import Html.Events
import Page
import Request
import Shared
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
    { counter : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { counter = 0 }, Cmd.none )



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Decrement ->
            ( { model | counter = model.counter - 1 }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Homepage"
    , body =
        [ Html.button [ Html.Events.onClick Increment ] [ Html.text "+" ]
        , Html.p [] [ Html.text ("Count: " ++ String.fromInt model.counter) ]
        , Html.button [ Html.Events.onClick Decrement ] [ Html.text "-" ]
        ]
    }

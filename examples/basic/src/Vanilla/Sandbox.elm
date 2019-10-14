module Vanilla.Sandbox exposing
    ( Model
    , Msg
    , init
    , main
    , update
    , view
    )

import Browser
import Html exposing (..)
import Html.Events as Events


main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


type alias Model =
    { counter : Int
    }


init : Model
init =
    { counter = 0
    }


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Counter" ]
        , div []
            [ button [ Events.onClick Increment ] [ text "+" ]
            , p [] [ text (String.fromInt model.counter) ]
            , button [ Events.onClick Decrement ] [ text "-" ]
            ]
        ]

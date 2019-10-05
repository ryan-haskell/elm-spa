module Pages.Counter exposing
    ( Model
    , Msg
    , init
    , title
    , update
    , view
    )

import Html exposing (..)
import Html.Events as Events


type alias Model =
    { counter : Int
    }


type Msg
    = Increment
    | Decrement


title : Model -> String
title model =
    "Counter: " ++ String.fromInt model.counter ++ " | elm-app"


init : Model
init =
    { counter = 0
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Decrement ->
            { model | counter = model.counter - 1 }

        Increment ->
            { model | counter = model.counter + 1 }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Counter!" ]
        , p [] [ text "Even the browser tab updates!" ]
        , div []
            [ button [ Events.onClick Decrement ] [ text "-" ]
            , text (String.fromInt model.counter)
            , button [ Events.onClick Increment ] [ text "+" ]
            ]
        ]

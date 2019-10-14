module Pages.Random exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , title
    , update
    , view
    )

import Flags exposing (Flags)
import Html exposing (..)
import Html.Events as Events
import Random


type alias Model =
    { roll : Maybe Int
    }


type Msg
    = Roll
    | GotOutcome Int


title : Model -> String
title model =
    "Random | elm-app"


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { roll = Nothing }
    , Cmd.none
    )


rollDice : Model -> ( Model, Cmd Msg )
rollDice model =
    ( model
    , Random.generate GotOutcome (Random.int 1 6)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            rollDice model

        GotOutcome value ->
            ( { model | roll = Just value }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Random!" ]
        , p [] [ text "Did somebody say 'random numbers pls'?" ]
        , div []
            [ button [ Events.onClick Roll ] [ text "Roll" ]
            , p []
                [ model.roll
                    |> Maybe.map String.fromInt
                    |> Maybe.withDefault "Click the button!"
                    |> text
                ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

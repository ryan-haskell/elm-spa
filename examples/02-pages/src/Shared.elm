module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Json.Decode as Json
import Request exposing (Request)


type alias Flags =
    Json.Value


type alias Model =
    { counter : Int
    }


type Msg
    = Increment
    | Decrement


init : Request -> Flags -> ( Model, Cmd Msg )
init _ _ =
    ( { counter = 0 }, Cmd.none )


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
            , Cmd.none
            )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none

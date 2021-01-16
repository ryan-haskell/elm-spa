module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    )

import Browser.Navigation exposing (Key)
import Json.Decode as Json
import Request exposing (Request)
import Url exposing (Url)


type alias Flags =
    Json.Value


type alias Model =
    {}


type Msg
    = NoOp


init : Request () -> Flags -> ( Model, Cmd Msg )
init _ flags =
    ( {}, Cmd.none )


update : Request () -> Msg -> Model -> ( Model, Cmd Msg )
update request msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Request () -> Model -> Sub Msg
subscriptions request model =
    Sub.none

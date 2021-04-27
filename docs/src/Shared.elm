module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    )

import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Domain.Index exposing (Index)
import Json.Decode as Json
import Request exposing (Request)
import Url exposing (Url)


type alias Flags =
    Json.Value


type alias Model =
    { index : Index
    }


type alias Token =
    ()


type Msg
    = NoOp



-- INIT


init : Request -> Flags -> ( Model, Cmd Msg )
init _ flags =
    ( Model
        (flags
            |> Json.decodeValue Domain.Index.decoder
            |> Result.withDefault []
        )
    , Cmd.none
    )



-- UPDATE


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update request msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Request -> Model -> Sub Msg
subscriptions request model =
    Sub.none

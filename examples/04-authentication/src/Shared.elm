module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    )

import Gen.Route
import Json.Decode as Json
import Request exposing (Request)
import Storage exposing (Storage)


type alias Flags =
    Json.Value


type alias Model =
    { storage : Storage
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init req flags =
    let
        model =
            { storage = Storage.fromJson flags }
    in
    ( model
    , if model.storage.user /= Nothing && req.route == Gen.Route.SignIn then
        Request.replaceRoute Gen.Route.SignIn req

      else
        Cmd.none
    )


type Msg
    = StorageUpdated Storage


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        StorageUpdated storage ->
            ( { model | storage = storage }
            , if Gen.Route.SignIn == req.route then
                Request.pushRoute Gen.Route.Home_ req

              else
                Cmd.none
            )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Storage.load StorageUpdated

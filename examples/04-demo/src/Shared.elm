module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , User
    , init
    , subscriptions
    , update
    )

import Gen.Route
import Json.Decode as Json
import Request exposing (Request)


type alias User =
    { name : String
    }



-- INIT


type alias Flags =
    Json.Value


type alias Model =
    { user : Maybe User
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init _ _ =
    ( { user = Nothing }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SignedIn String
    | SignedOut


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        SignedIn name ->
            ( { model | user = Just { name = name } }
            , Request.pushRoute Gen.Route.Home_ req
            )

        SignedOut ->
            ( { model | user = Nothing }
            , Cmd.none
            )


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none

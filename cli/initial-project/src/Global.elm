module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Generated.Route exposing (Route)


type alias Flags =
    ()


type alias Model =
    {}


type Msg
    = NoOp


init : { navigate : Route -> Cmd msg } -> Flags -> ( Model, Cmd Msg, Cmd msg )
init _ _ =
    ( {}
    , Cmd.none
    , Cmd.none
    )


update : { navigate : Route -> Cmd msg } -> Msg -> Model -> ( Model, Cmd Msg, Cmd msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

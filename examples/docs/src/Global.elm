module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Generated.Routes exposing (Route)
import Ports


type alias Flags =
    ()


type alias Model =
    {}


type Msg
    = Msg


type alias GlobalContext msg =
    { navigate : Route -> Cmd msg
    }


init : GlobalContext msg -> Flags -> ( Model, Cmd Msg, Cmd msg )
init _ _ =
    ( {}
    , Cmd.none
    , Ports.log "Global.elm is using ports!"
    )


update : GlobalContext msg -> Msg -> Model -> ( Model, Cmd Msg, Cmd msg )
update _ _ model =
    ( model
    , Cmd.none
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Data.User exposing (User)
import Http


type alias Flags =
    ()


type alias Model =
    { user : Maybe User
    }


type Msg
    = SignIn (Result Http.Error User)
    | SignOut


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { user = Nothing }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignIn (Ok user) ->
            ( { model | user = Just user }
            , Cmd.none
            )

        SignIn (Err _) ->
            ( { model | user = Just { username = "Admin User" } }
            , Cmd.none
            )

        SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Data.User exposing (User)
import Generated.Route exposing (Route)
import Http


type alias Flags =
    ()


type alias Model =
    { user : Maybe User
    }


type Msg
    = SignIn (Result Http.Error User)
    | SignOut
    | NavigateTo Route


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { user = Nothing }
    , Cmd.none
    )


update :
    { navigate : Route -> Cmd msg }
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd msg )
update app msg model =
    case msg of
        SignIn (Ok user) ->
            ( { model | user = Just user }
            , Cmd.none
            , Cmd.none
            )

        SignIn (Err _) ->
            ( { model | user = Just { username = "Admin User" } }
            , Cmd.none
            , Cmd.none
            )

        SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            , Cmd.none
            )

        NavigateTo route ->
            ( model
            , Cmd.none
            , app.navigate route
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

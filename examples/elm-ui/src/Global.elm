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
    { user : Maybe String
    }


type Msg
    = SignIn String
    | SignOut
    | NavigateTo Route


init :
    { navigate : Route -> Cmd msg }
    -> Flags
    -> ( Model, Cmd Msg, Cmd msg )
init _ _ =
    ( { user = Nothing }
    , Cmd.none
    , Cmd.none
    )


update :
    { navigate : Route -> Cmd msg }
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd msg )
update app msg model =
    case msg of
        SignIn user ->
            ( { model | user = Just user }
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

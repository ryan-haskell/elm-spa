module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Generated.Routes as Routes exposing (Route, routes)


type alias Flags =
    ()


type alias Model =
    { user : Maybe String
    }


type Msg
    = SignIn String
    | SignOut


type alias Commands msg =
    { navigate : Route -> Cmd msg
    }


init : Commands msg -> Flags -> ( Model, Cmd Msg, Cmd msg )
init _ _ =
    ( { user = Nothing }
    , Cmd.none
    , Cmd.none
    )


update : Commands msg -> Msg -> Model -> ( Model, Cmd Msg, Cmd msg )
update commands msg model =
    case msg of
        SignIn user ->
            ( { model | user = Just user }
            , Cmd.none
            , commands.navigate routes.top
            )

        SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

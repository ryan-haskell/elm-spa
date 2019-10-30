module Pages.SignIn exposing (Model, Msg, page)

import Application.Page as Page
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Generated.Route as Route
import Global
import Task


type Model
    = Model


type Msg
    = SignIn
    | SignOut


page =
    Page.component
        { title = \_ _ -> "Sign in"
        , init = init
        , update = update
        , subscriptions = \_ _ -> Sub.none
        , view = view
        }


init : Global.Model -> () -> ( Model, Cmd Msg, Cmd Global.Msg )
init _ _ =
    ( Model
    , Cmd.none
    , Cmd.none
    )


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update _ msg model =
    case msg of
        SignIn ->
            ( model
            , Cmd.none
            , Cmd.batch
                [ send (Global.SignIn "Admin User")
                , send (Global.NavigateTo (Route.Index ()))
                ]
            )

        SignOut ->
            ( model
            , Cmd.none
            , send Global.SignOut
            )


send : msg -> Cmd msg
send =
    Task.succeed >> Task.perform identity


view : Global.Model -> Model -> Element Msg
view global _ =
    column
        [ spacing 32 ]
        [ text "Sign in"
        , case global.user of
            Just _ ->
                Input.button
                    [ paddingXY 24 12
                    , Background.color (rgb 0.75 0.25 0)
                    , Font.color (rgb 1 1 1)
                    ]
                    { onPress = Just SignOut
                    , label = text "Sign out"
                    }

            Nothing ->
                Input.button
                    [ paddingXY 24 12
                    , Background.color (rgb 0 0.5 0.75)
                    , Font.color (rgb 1 1 1)
                    ]
                    { onPress = Just SignIn
                    , label = text "Sign in"
                    }
        ]

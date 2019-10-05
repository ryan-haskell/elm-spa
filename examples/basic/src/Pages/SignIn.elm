module Pages.SignIn exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , title
    , update
    , view
    )

import Application.Page exposing (Context)
import Context
import Data.User as User exposing (User)
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Route exposing (Route)
import Utils.Cmd


type alias Model =
    { username : String
    , password : String
    }


type Msg
    = Update Field String
    | AttemptSignIn


type Field
    = Username
    | Password


title : Context Flags Route Context.Model -> Model -> String
title { context } model =
    case context.user of
        Just user ->
            "Sign out " ++ User.username user ++ " | elm-app"

        Nothing ->
            "Sign in | elm-app"


init :
    Context Flags Route Context.Model
    -> ( Model, Cmd Msg, Cmd Context.Msg )
init _ =
    Utils.Cmd.pure { username = "", password = "" }


update :
    Context Flags Route Context.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd Context.Msg )
update _ msg model =
    case msg of
        Update Username value ->
            Utils.Cmd.pure { model | username = value }

        Update Password value ->
            Utils.Cmd.pure { model | password = value }

        AttemptSignIn ->
            ( model
            , Cmd.none
            , User.signIn
                { username = model.username
                , password = model.password
                , msg = Context.SignIn
                }
            )


view :
    Context Flags Route Context.Model
    -> Model
    -> Html Msg
view _ model =
    div []
        [ h1 [] [ text "Sign in" ]
        , p [] [ text "and update some user state!" ]
        , Html.form [ Events.onSubmit AttemptSignIn ]
            [ viewInput
                { label = "Username"
                , fieldType = "text"
                , value = model.username
                , onInput = Update Username
                }
            , viewInput
                { label = "Password"
                , fieldType = "password"
                , value = model.password
                , onInput = Update Password
                }
            , p []
                [ button
                    [ Attr.class "button"
                    , Attr.type_ "submit"
                    ]
                    [ text "Sign in"
                    ]
                ]
            ]
        ]


viewInput :
    { label : String
    , fieldType : String
    , value : String
    , onInput : String -> msg
    }
    -> Html msg
viewInput options =
    label []
        [ div [] [ text options.label ]
        , input
            [ Attr.value options.value
            , Attr.type_ options.fieldType
            , Events.onInput options.onInput
            ]
            []
        ]


subscriptions :
    Context Flags Route Context.Model
    -> Model
    -> Sub Msg
subscriptions _ model =
    Sub.none

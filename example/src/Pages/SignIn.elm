module Pages.SignIn exposing (Model, Msg, Route, page)

import Application.Page as Application
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events


type alias Model =
    { username : String
    , password : String
    }


type Msg
    = Updated Field String
    | FormSubmitted


type Field
    = Username
    | Password


type alias Route =
    ()


page =
    Application.sandbox
        { init = always init
        , update = update
        , view = view
        }


init : Model
init =
    { username = ""
    , password = ""
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Updated Username username ->
            { model | username = username }

        Updated Password password ->
            { model | password = password }

        FormSubmitted ->
            model


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Sign in" ]
        , Html.form
            [ Events.onSubmit FormSubmitted ]
            [ viewInput
                { label = "Username"
                , value = model.username
                , onInput = Updated Username
                , type_ = "text"
                }
            , viewInput
                { label = "Password"
                , value = model.password
                , onInput = Updated Password
                , type_ = "password"
                }
            , button [] [ text "Sign in" ]
            ]
        ]


viewInput :
    { label : String
    , value : String
    , onInput : String -> msg
    , type_ : String
    }
    -> Html msg
viewInput config =
    label
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        , Attr.style "align-items" "flex-start"
        , Attr.style "margin" "1rem 0"
        ]
        [ span [] [ text config.label ]
        , input
            [ Attr.type_ config.type_
            , Events.onInput config.onInput
            , Attr.value config.value
            ]
            []
        ]

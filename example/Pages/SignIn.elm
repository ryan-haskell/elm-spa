module Pages.SignIn exposing (Model, Msg, page)

import App.Page
import Components.Button
import Components.Styles as Styles
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Generated.Params as Params
import Global
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Utils.Page exposing (Page)


type alias Model =
    { username : String
    , password : String
    }


type Msg
    = UpdatedField Field String
    | ClickedSignIn


type Field
    = Username
    | Password


page : Page Params.SignIn Model Msg model msg appMsg
page =
    App.Page.component
        { title = always "sign in | elm-spa"
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }



-- INIT


init : Params.SignIn -> ( Model, Cmd Msg, Cmd Global.Msg )
init flags =
    ( { username = ""
      , password = ""
      }
    , Cmd.none
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update msg model =
    case msg of
        UpdatedField Username value ->
            ( { model | username = value }
            , Cmd.none
            , Cmd.none
            )

        UpdatedField Password value ->
            ( { model | password = value }
            , Cmd.none
            , Cmd.none
            )

        ClickedSignIn ->
            ( model
            , Cmd.none
            , App.Page.send <|
                Global.SignIn model.username
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Element Msg
view model =
    el [ centerX, centerY ] <|
        form
            { onSubmit = ClickedSignIn
            }
            [ spacing 32 ]
            [ el [ Font.size 24, Font.semiBold ]
                (text "Sign in")
            , column [ spacing 16 ]
                [ viewField
                    { label = "Username"
                    , onChange = UpdatedField Username
                    , inputType = TextInput
                    , value = model.username
                    }
                , viewField
                    { label = "Password"
                    , onChange = UpdatedField Password
                    , inputType = PasswordInput
                    , value = model.password
                    }
                ]
            , el [ alignRight ] <|
                if String.isEmpty model.username then
                    Input.button (Styles.button ++ [ alpha 0.6 ])
                        { onPress = Nothing
                        , label = text "Sign In"
                        }

                else
                    Input.button (Styles.button ++ [ htmlAttribute (Attr.type_ "submit") ])
                        { onPress = Just ClickedSignIn
                        , label = text "Sign In"
                        }
            ]


form : { onSubmit : msg } -> List (Attribute msg) -> List (Element msg) -> Element msg
form config attrs children =
    Element.html
        (Html.form
            [ Events.onSubmit config.onSubmit ]
            [ toHtml (column attrs children)
            ]
        )


toHtml : Element msg -> Html msg
toHtml =
    Element.layoutWith { options = [ Element.noStaticStyleSheet ] } []


type InputType
    = TextInput
    | PasswordInput


viewField :
    { inputType : InputType
    , label : String
    , onChange : String -> msg
    , value : String
    }
    -> Element msg
viewField config =
    let
        styles =
            { field =
                [ paddingXY 4 4
                , Border.rounded 0
                , Border.widthEach
                    { top = 0
                    , left = 0
                    , right = 0
                    , bottom = 1
                    }
                ]
            , label =
                [ Font.size 16
                , Font.semiBold
                ]
            }

        label =
            Input.labelAbove
                styles.label
                (text config.label)
    in
    case config.inputType of
        TextInput ->
            Input.text styles.field
                { onChange = config.onChange
                , text = config.value
                , placeholder = Nothing
                , label = label
                }

        PasswordInput ->
            Input.currentPassword styles.field
                { onChange = config.onChange
                , text = config.value
                , placeholder = Nothing
                , label = label
                , show = False
                }

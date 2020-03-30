module Components exposing
    ( footer
    , layout
    , navbar
    )

import Browser exposing (Document)
import Data.Modal as Modal exposing (Modal)
import Data.SignInForm exposing (SignInForm)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href)
import Html.Events as Events
import Generated.Route as Route



-- LAYOUT


layout :
    { page : Document msg
    , global :
        { global
            | modal : Maybe Modal
            , user : Maybe User
        }
    , actions :
        { onSignOut : msg
        , openSignInModal : msg
        , closeModal : msg
        , attemptSignIn : msg
        , onSignInEmailInput : String -> msg
        , onSignInPasswordInput : String -> msg
        }
    }
    -> Document msg
layout { page, actions, global } =
    { title = page.title
    , body =
        [ div [ class "container pad--medium column spacing--large h--fill" ]
            [ navbar { user = global.user, actions = actions }
            , div [ class "column spacing--large", Attr.style "flex" "1 0 auto" ] page.body
            , footer
            , global.modal
                |> Maybe.map (viewModal actions)
                |> Maybe.withDefault (text "")
            ]
        ]
    }



-- NAVBAR


navbar :
    { user : Maybe User
    , actions : { actions | openSignInModal : msg, onSignOut : msg }
    }
    -> Html msg
navbar ({ actions } as options) =
    header [ class "container" ]
        [ div [ class "row spacing--between center-y" ]
            [ a [ class "link font--h5 font--bold", href "/" ] [ text "home" ]
            , div [ class "row spacing--medium center-y" ]
                [ a [ class "link", href "/about" ] [ text "about" ]
                , a [ class "link", href "/posts" ] [ text "posts" ]
                , case options.user of
                    Just user ->
                        a [ class "link", href (Route.toHref Route.Profile) ] [ text "profile" ]

                    Nothing ->
                        button [ class "button", Events.onClick actions.openSignInModal ] [ text "sign in" ]
                ]
            ]
        ]



-- FOOTER


footer : Html msg
footer =
    Html.footer [ class "container py--medium" ]
        [ text "built with elm, 2020"
        ]



-- MODAL


viewModal :
    { actions
        | closeModal : msg
        , attemptSignIn : msg
        , onSignInEmailInput : String -> msg
        , onSignInPasswordInput : String -> msg
    }
    -> Modal
    -> Html msg
viewModal actions modal_ =
    case modal_ of
        Modal.SignInModal { email, password } ->
            modal
                { title = "Sign in"
                , body =
                    form [ class "column spacing--medium", Events.onSubmit actions.attemptSignIn ]
                        [ emailField
                            { label = "Email"
                            , value = email
                            , onInput = actions.onSignInEmailInput
                            }
                        , passwordField
                            { label = "Password"
                            , value = password
                            , onInput = actions.onSignInPasswordInput
                            }
                        , button [ class "button" ] [ text "Sign in" ]
                        ]
                , actions = actions
                }


modal :
    { title : String
    , body : Html msg
    , actions : { actions | closeModal : msg }
    }
    -> Html msg
modal ({ actions } as options) =
    div [ class "fixed--full" ]
        [ div [ class "absolute--full bg--overlay", Events.onClick actions.closeModal ] []
        , div [ class "column spacing--large pad--large absolute--center min-width--480 bg--white" ]
            [ div [ class "row spacing--between center-y" ]
                [ h3 [ class "font--h3" ] [ text options.title ]
                , button [ class "modal__close", Events.onClick actions.closeModal ] [ text "✖️" ]
                ]
            , options.body
            ]
        ]



-- FORMS


inputField :
    String
    -> { label : String, value : String, onInput : String -> msg }
    -> Html msg
inputField type_ options =
    label [ class "column spacing--small" ]
        [ span [] [ text options.label ]
        , input [ Attr.type_ type_, Attr.value options.value, Events.onInput options.onInput ] []
        ]


emailField :
    { label : String, value : String, onInput : String -> msg }
    -> Html msg
emailField =
    inputField "email"


passwordField :
    { label : String, value : String, onInput : String -> msg }
    -> Html msg
passwordField =
    inputField "password"

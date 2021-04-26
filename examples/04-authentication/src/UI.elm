module UI exposing (h1, layout)

import Gen.Route as Route exposing (Route)
import Html exposing (Html)
import Html.Attributes as Attr


layout : List (Html msg) -> List (Html msg)
layout children =
    let
        viewLink : String -> Route -> Html msg
        viewLink label route =
            Html.a [ Attr.href (Route.toHref route) ] [ Html.text label ]
    in
    [ Html.div [ Attr.style "margin" "2rem" ]
        [ Html.header [ Attr.style "margin-bottom" "1rem" ]
            [ Html.strong [ Attr.style "margin-right" "1rem" ] [ viewLink "Home" Route.Home_ ]
            , viewLink "Sign in" Route.SignIn
            ]
        , Html.main_ [] children
        ]
    ]


h1 : String -> Html msg
h1 label =
    Html.h1 [] [ Html.text label ]

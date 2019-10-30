module Components.Navbar exposing (view)

import Generated.Route as Route exposing (Route)
import Generated.Route.Settings as Settings
import Html exposing (..)
import Html.Attributes as Attr


view : Html msg
view =
    header
        [ Attr.class "navbar"
        , Attr.style "line-height" "2"
        , Attr.style "display" "flex"
        , Attr.style "justify-content" "space-between"
        , Attr.style "flex-wrap" "wrap"
        ]
        [ div [] <|
            List.map viewLink
                [ ( "Home", Route.Index () )
                , ( "Counter", Route.Counter () )
                , ( "Cats", Route.Random () )
                , ( "Settings", Route.Settings (Settings.Account ()) )
                ]
        , div []
            [ viewLink ( "Sign in", Route.SignIn () )
            ]
        ]


viewLink : ( String, Route ) -> Html msg
viewLink ( label, route ) =
    a
        [ Attr.href (Route.toPath route)
        , Attr.style "margin-right" "1rem"
        , Attr.style "white-space" "nowrap"
        ]
        [ text label
        ]

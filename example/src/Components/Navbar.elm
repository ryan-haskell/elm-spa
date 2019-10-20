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
        , Attr.style "flex-wrap" "wrap"
        ]
    <|
        List.map viewLink
            [ ( "Home", Route.Homepage () )
            , ( "Counter", Route.Counter () )
            , ( "Cats", Route.Random () )
            , ( "User", Route.Users_Slug "alice" )
            , ( "Settings", Route.Settings (Settings.Account ()) )
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

module Components.Navbar exposing (view)

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
            [ ( "Home", "/" )
            , ( "Counter", "/counter" )
            , ( "Cats", "/random" )
            , ( "Settings", "/settings/account" )
            ]


viewLink : ( String, String ) -> Html msg
viewLink ( label, path ) =
    a
        [ Attr.href path
        , Attr.style "margin-right" "1rem"
        , Attr.style "white-space" "nowrap"
        ]
        [ text label
        ]

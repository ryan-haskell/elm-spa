module Components.Navbar exposing (view)

import Html exposing (..)
import Html.Attributes as Attr


view : Html msg
view =
    header
        [ Attr.class "navbar"
        , Attr.style "margin-bottom" "32px"
        ]
        (List.map viewLink
            [ ( "homepage", "/" )
            , ( "docs", "/docs" )
            ]
        )


viewLink : ( String, String ) -> Html msg
viewLink ( label, url ) =
    a
        [ Attr.href url
        , Attr.style "margin-right" "16px"
        ]
        [ text label
        ]

module Components.Navbar exposing (view)

import Generated.Route as Route exposing (Route)
import Html exposing (..)
import Html.Attributes as Attr


view : Html msg
view =
    header
        [ Attr.class "navbar"
        , Attr.style "margin-bottom" "32px"
        ]
        (List.map viewLink
            [ ( "homepage", Route.Index () )
            , ( "docs", Route.Docs () )
            ]
        )


viewLink : ( String, Route ) -> Html msg
viewLink ( label, route ) =
    a
        [ Attr.href (Route.toPath route)
        , Attr.style "margin-right" "16px"
        ]
        [ text label
        ]

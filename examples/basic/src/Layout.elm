module Layout exposing (view)

import Generated.Route as Route exposing (Route)
import Html exposing (..)
import Html.Attributes as Attr


view : { page : Html msg } -> Html msg
view { page } =
    div
        [ Attr.style "margin" "2rem auto"
        , Attr.style "max-width" "720px"
        ]
        [ header [ Attr.class "navbar" ]
            (List.map viewLink
                [ ( "Homepage", Route.Homepage )
                , ( "Counter", Route.Counter )
                , ( "Random", Route.Random )
                ]
            )
        , page
        ]


viewLink : ( String, Route ) -> Html msg
viewLink ( label, route ) =
    a
        [ Attr.href (Route.toPath route)
        , Attr.style "margin-right" "1rem"
        ]
        [ text label
        ]

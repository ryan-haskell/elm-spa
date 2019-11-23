module Layout exposing (view)

import Generated.Routes as Routes exposing (Route, routes)
import Html exposing (..)
import Html.Attributes as Attr
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Html msg
view { page, route } =
    div [ Attr.class "app" ]
        [ viewHeader route
        , page
        ]


viewHeader : Route -> Html msg
viewHeader currentRoute =
    header
        [ Attr.class "navbar"
        ]
        [ viewLink currentRoute ( "home", routes.top )
        , viewLink currentRoute ( "nowhere", routes.notFound )
        ]


viewLink : Route -> ( String, Route ) -> Html msg
viewLink currentRoute ( label, route ) =
    if currentRoute == route then
        span
            [ Attr.class "link link--active" ]
            [ text label ]

    else
        a
            [ Attr.class "link"
            , Attr.href (Routes.toPath route)
            ]
            [ text label ]

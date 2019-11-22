module Layouts.Docs exposing (view)

import Utils.Styles as Styles
import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    column [ width fill ]
        [ row [ spacing 16 ] <|
            List.map (viewLink route)
                [ { label = "elm"
                  , route = routes.docs_dynamic "elm"
                  }
                , { label = "elm-spa"
                  , route = routes.docs_dynamic "elm-spa"
                  }
                ]
        , page
        ]


viewLink : Route -> { label : String, route : Route } -> Element msg
viewLink activeRoute { label, route } =
    if route == activeRoute then
        link
            [ Font.underline
            ]
            { url = Routes.toPath route
            , label = text label
            }

    else
        link
            Styles.link
            { url = Routes.toPath route
            , label = text label
            }

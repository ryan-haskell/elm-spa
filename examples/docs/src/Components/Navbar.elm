module Components.Navbar exposing (view)

import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Ui exposing (colors, styles)


view : Route -> Element msg
view currentRoute =
    row
        [ spacing 24
        , centerX
        , width fill
        ]
        [ row [ Font.color colors.coral, spacing 20 ]
            [ el [ Font.semiBold, Font.size 20 ]
                (viewLink currentRoute ( "elm-spa", routes.top ))
            , viewLink currentRoute ( "docs", routes.docs_top )
            , viewLink currentRoute ( "guide", routes.guide )
            ]
        , el [ alignRight ] <|
            link styles.button
                { label = text "get started"
                , url = "/guide"
                }
        ]


viewLink : Route -> ( String, Route ) -> Element msg
viewLink currentRoute ( label, route ) =
    if currentRoute == route then
        el styles.link.disabled
            (text label)

    else
        link styles.link.enabled
            { label = text label
            , url = Routes.toPath route
            }

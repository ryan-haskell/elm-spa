module Layout exposing (view)

import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    column [ height fill, width fill ]
        [ viewHeader route
        , page
        ]


viewHeader : Route -> Element msg
viewHeader currentRoute =
    row
        [ spacing 24
        , paddingEach { top = 32, left = 16, right = 16, bottom = 0 }
        , centerX
        , width (fill |> maximum 480)
        ]
        [ viewLink currentRoute ( "home", routes.top )
        , viewLink currentRoute ( "nowhere", routes.notFound )
        ]


viewLink : Route -> ( String, Route ) -> Element msg
viewLink currentRoute ( label, route ) =
    if currentRoute == route then
        el
            [ Font.underline
            , Font.color (rgb255 204 75 75)
            , alpha 0.5
            , Font.size 16
            ]
            (text label)

    else
        link
            [ Font.underline
            , Font.color (rgb255 204 75 75)
            , Font.size 16
            , mouseOver [ alpha 0.5 ]
            ]
            { label = text label
            , url = Routes.toPath route
            }

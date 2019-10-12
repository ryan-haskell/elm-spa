module Components.LinkPage exposing (view)

import Element exposing (..)
import Element.Font as Font
import Route exposing (Route)


view :
    { title : String
    , link : { label : String, route : Route }
    }
    -> Element msg
view options =
    column [ centerX, centerY, Font.center, spacing 24 ]
        [ el [ Font.bold, Font.size 48, centerX ] (text options.title)
        , link
            [ Font.underline
            , Font.color (rgb 0 0.5 0.85)
            , centerX
            , mouseOver
                [ alpha 0.75
                ]
            ]
            { url = Route.toPath options.link.route
            , label = text options.link.label
            }
        ]

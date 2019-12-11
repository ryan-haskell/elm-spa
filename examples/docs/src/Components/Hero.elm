module Components.Hero exposing (Options, view)

import Element exposing (..)
import Element.Font as Font
import Element.Region as Region
import Ui exposing (styles)


type alias Options =
    { title : String
    , subtitle : String
    , links :
        List
            { label : String
            , url : String
            }
    }


view : Options -> Element msg
view options =
    column
        [ paddingEach
            { top = 120
            , left = 0
            , right = 0
            , bottom = 64
            }
        , centerX
        , spacing 24
        ]
        [ column [ spacing 16, centerX ]
            [ el
                [ Font.size 64
                , Font.bold
                , centerX
                , Region.heading 1
                ]
                (text options.title)
            , el
                [ Font.size 24
                , centerX
                , alpha 0.5
                , Region.heading 2
                ]
                (text options.subtitle)
            ]
        , wrappedRow [ spacing 12, centerX ] <|
            List.map
                (\{ label, url } ->
                    link styles.button
                        { label = text label
                        , url = url
                        }
                )
                options.links
        ]

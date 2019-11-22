module Utils.Styles exposing
    ( button
    , colors
    , fonts
    , h1
    , h3
    , link
    , transition
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as Attr


colors =
    { white = rgb 1 1 1
    , jet = rgb255 40 40 40
    , coral = rgb255 204 75 75
    }


fonts =
    { sans =
        [ Font.external
            { name = "IBM Plex Sans"
            , url = "https://fonts.googleapis.com/css?family=IBM+Plex+Sans:400,400i,600,600i&display=swap"
            }
        , Font.serif
        ]
    }


link : List (Attribute msg)
link =
    [ Font.underline
    , Font.color colors.coral
    , transition
        { property = "opacity"
        , duration = 150
        }
    , mouseOver
        [ alpha 0.6
        ]
    ]


button : List (Attribute msg)
button =
    [ paddingXY 16 8
    , Font.size 14
    , Border.color colors.coral
    , Font.color colors.coral
    , Background.color colors.white
    , Border.width 2
    , Border.rounded 4
    , pointer
    , transition
        { property = "all"
        , duration = 150
        }
    , mouseOver
        [ Font.color colors.white
        , Background.color colors.coral
        ]
    ]


h1 : List (Attribute msg) -> Element msg -> Element msg
h1 =
    elWith
        [ Font.family fonts.sans
        , Font.semiBold
        , Font.size 64
        ]


h3 : List (Attribute msg) -> Element msg -> Element msg
h3 =
    elWith
        [ Font.family fonts.sans
        , Font.semiBold
        , Font.size 36
        ]


transition :
    { property : String
    , duration : Int
    }
    -> Attribute msg
transition { property, duration } =
    Element.htmlAttribute
        (Attr.style
            "transition"
            (property ++ " " ++ String.fromInt duration ++ "ms ease-in-out")
        )


elWith : List (Attribute msg) -> List (Attribute msg) -> Element msg -> Element msg
elWith styles otherStyles =
    el ([ Element.htmlAttribute (Attr.class "markdown") ] ++ styles ++ otherStyles)

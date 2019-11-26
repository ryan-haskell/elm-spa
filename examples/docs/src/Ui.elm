module Ui exposing
    ( colors
    , container
    , markdown
    , sections
    , styles
    , transition
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as Attr
import Markdown


colors : { coral : Color, white : Color }
colors =
    { coral = rgb255 200 75 85
    , white = rgb255 255 255 255
    }


styles :
    { button : List (Attribute msg)
    , link :
        { enabled : List (Attribute msg)
        , disabled : List (Attribute msg)
        }
    }
styles =
    { link =
        { enabled =
            [ Font.underline
            , transition
                { duration = 200
                , props = [ "opacity" ]
                }
            , mouseOver [ alpha 0.5 ]
            ]
        , disabled =
            [ alpha 0.5
            ]
        }
    , button =
        [ centerX
        , Font.size 14
        , Font.semiBold
        , Border.solid
        , Border.width 2
        , Border.rounded 4
        , paddingXY 24 8
        , Font.color colors.coral
        , Border.color colors.coral
        , Background.color colors.white
        , pointer
        , transition
            { duration = 200
            , props = [ "background", "color" ]
            }
        , mouseOver
            [ Background.color colors.coral
            , Font.color colors.white
            ]
        ]
    }


sections : List (Element msg) -> Element msg
sections =
    column [ spacing 32, width fill ]


markdown : String -> Element msg
markdown =
    let
        options =
            Markdown.defaultOptions
                |> (\o -> { o | sanitize = False })
    in
    Markdown.toHtmlWith options [ Attr.class "markdown" ]
        >> Element.html
        >> List.singleton
        >> paragraph []


transition : { props : List String, duration : Int } -> Attribute msg
transition options =
    options.props
        |> List.map
            (\prop ->
                String.join " "
                    [ prop
                    , String.fromInt options.duration ++ "ms"
                    , "ease-in-out"
                    ]
            )
        |> String.join ", "
        |> Attr.style "transition"
        |> Element.htmlAttribute


container : Element msg -> Element msg
container =
    el
        [ centerX
        , width (fill |> maximum 540)
        ]

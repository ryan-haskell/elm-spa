module Ui exposing
    ( colors
    , container
    , markdown
    , markdownArticle
    , sections
    , styles
    , transition
    , webDataMarkdownArticle
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as Attr
import Markdown
import Utils.Markdown as Markdown exposing (Markdown(..))
import Utils.WebData as WebData exposing (WebData(..))


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


markdownArticle :
    { title : String
    , subtitle : Maybe String
    , content : String
    }
    -> Element msg
markdownArticle options =
    column [ height fill ]
        [ column [ paddingXY 0 64, spacing 8 ] <|
            List.concat
                [ [ el [ Font.size 48, Font.semiBold ] (text options.title) ]
                , options.subtitle
                    |> Maybe.map (text >> List.singleton >> paragraph [ alpha 0.5, Font.size 20 ])
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault []
                ]
        , markdown options.content
        ]


webDataMarkdownArticle :
    { fallbackTitle : String
    , markdown : WebData (Markdown { title : String, description : Maybe String })
    }
    -> Element msg
webDataMarkdownArticle options =
    case options.markdown of
        Loading ->
            el [ height fill ] (text "")

        Success (Markdown.WithFrontmatter { frontmatter, content }) ->
            markdownArticle
                { title = frontmatter.title
                , subtitle = frontmatter.description
                , content = content
                }

        Success (Markdown.WithoutFrontmatter content) ->
            markdownArticle
                { title = options.fallbackTitle
                , subtitle = Nothing
                , content = content
                }

        Failure _ ->
            markdownArticle
                { title = "huh."
                , subtitle = Just "i couldn't find that article."
                , content = ""
                }


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

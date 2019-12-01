module Ui exposing
    ( colors
    , markdown
    , markdownArticle
    , sections
    , styles
    , transition
    , viewNextArticle
    , viewSidebar
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
    column [ width fill, height fill ]
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



-- DOCS SIDEBAR


type alias SidebarOptions route =
    { current : route
    , links : List (SideItem route)
    , toPath : route -> String
    }


type SideItem route
    = Heading String
    | Link ( String, route )


type Match route
    = NoMatchFound
    | FoundMatch
    | HereItIs ( String, route )


nextArticle : route -> List (SideItem route) -> Maybe ( String, route )
nextArticle activeRoute items =
    items
        |> List.filterMap
            (\item ->
                case item of
                    Heading _ ->
                        Nothing

                    Link tuple ->
                        Just tuple
            )
        |> List.foldl
            (\item match ->
                case match of
                    NoMatchFound ->
                        if Tuple.second item == activeRoute then
                            FoundMatch

                        else
                            NoMatchFound

                    FoundMatch ->
                        HereItIs item

                    HereItIs i ->
                        HereItIs i
            )
            NoMatchFound
        |> (\match ->
                case match of
                    NoMatchFound ->
                        Nothing

                    FoundMatch ->
                        Nothing

                    HereItIs item ->
                        Just item
           )


viewNextArticle :
    { current : route
    , links : List (SideItem route)
    , toPath : route -> String
    }
    -> Element msg
viewNextArticle options =
    (\link -> paragraph [ Font.size 20 ] [ el [ Font.semiBold ] <| text "next up: ", link ]) <|
        case nextArticle options.current options.links of
            Just ( label, r ) ->
                link (Font.color colors.coral :: styles.link.enabled)
                    { label = text label
                    , url = options.toPath r
                    }

            Nothing ->
                link (Font.color colors.coral :: styles.link.enabled)
                    { label = text "the guide"
                    , url = "/guide"
                    }


viewSidebar :
    SidebarOptions route
    -> Element msg
viewSidebar options =
    column
        [ alignTop
        , spacing 16
        , width (px 180)
        , paddingEach { top = 84, left = 0, right = 0, bottom = 0 }
        ]
        [ el [ Font.size 24, Font.semiBold ] (text "docs")
        , column [ spacing 8 ] (List.map (viewSideLink options) options.links)
        ]


viewSideLink : SidebarOptions route -> SideItem route -> Element msg
viewSideLink options item =
    case item of
        Heading label ->
            el
                [ alpha 0.5
                , Font.size 18
                , Font.semiBold
                , paddingEach { top = 8, left = 0, right = 0, bottom = 0 }
                ]
                (text label)

        Link ( label, route ) ->
            let
                linkStyles =
                    if route == options.current then
                        styles.link.disabled

                    else
                        styles.link.enabled
            in
            link (Font.color colors.coral :: linkStyles)
                { label = text label
                , url = options.toPath route
                }

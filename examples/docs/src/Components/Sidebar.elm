module Components.Sidebar exposing
    ( viewDocLinks
    , viewGuideLinks
    , viewNextDocsArticle
    , viewNextGuideArticle
    )

import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Ui exposing (colors, styles)


type SideItem
    = Heading String
    | Link ( String, Route )


guideLinks : List SideItem
guideLinks =
    [ Link ( "intro", routes.guide )
    , Link ( "installation", routes.guide_dynamic "installation" )
    , Link ( "getting started", routes.guide_dynamic "getting-started" )
    ]


docsLinks : List SideItem
docsLinks =
    [ Link ( "overview", routes.docs_top )
    , Heading "elm-spa"
    , Link ( "overview", routes.docs_dynamic "elm-spa" )
    , Link ( "elm-spa init", routes.docs_dynamic_dynamic "elm-spa" "init" )
    , Link ( "elm-spa add", routes.docs_dynamic_dynamic "elm-spa" "add" )
    , Link ( "elm-spa build", routes.docs_dynamic_dynamic "elm-spa" "build" )
    , Heading "pages"
    , Link ( "overview", routes.docs_dynamic "pages" )
    , Link ( "static", routes.docs_dynamic_dynamic "pages" "static" )
    , Link ( "sandbox", routes.docs_dynamic_dynamic "pages" "sandbox" )
    , Link ( "element", routes.docs_dynamic_dynamic "pages" "element" )
    , Link ( "component", routes.docs_dynamic_dynamic "pages" "component" )
    , Heading "layouts"
    , Link ( "overview", routes.docs_dynamic "layouts" )
    , Link ( "transitions", routes.docs_dynamic_dynamic "layouts" "transitions" )
    , Heading "other things"
    , Link ( "components", routes.docs_dynamic "components" )
    , Link ( "deploying", routes.docs_dynamic "deploying" )
    , Link ( "faqs", routes.docs_dynamic "faqs" )
    ]


type Match
    = NoMatchFound
    | FoundMatch
    | HereItIs ( String, Route )


nextArticle : Route -> List SideItem -> Maybe ( String, Route )
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


viewNextDocsArticle =
    viewNextArticle
        { items = docsLinks
        , nextUp =
            { label = text "the guide"
            , url = "/guide"
            }
        }


viewNextGuideArticle =
    viewNextArticle
        { items = guideLinks
        , nextUp =
            { label = text "the docs"
            , url = "/docs"
            }
        }


viewNextArticle :
    { nextUp :
        { label : Element msg
        , url : String
        }
    , items : List SideItem
    }
    -> Route
    -> Element msg
viewNextArticle options route =
    (\link -> paragraph [ Font.size 20 ] [ el [ Font.semiBold ] <| text "next up: ", link ]) <|
        case nextArticle route options.items of
            Just ( label, r ) ->
                link (Font.color colors.coral :: styles.link.enabled)
                    { label = text label
                    , url = Routes.toPath r
                    }

            Nothing ->
                link (Font.color colors.coral :: styles.link.enabled)
                    options.nextUp


viewDocLinks : Route -> Element msg
viewDocLinks =
    view
        { items = docsLinks
        , heading = "docs"
        }


viewGuideLinks : Route -> Element msg
viewGuideLinks =
    view
        { items = guideLinks
        , heading = "guide"
        }


view : { heading : String, items : List SideItem } -> Route -> Element msg
view { heading, items } activeRoute =
    column
        [ alignTop
        , spacing 16
        , width (px 200)
        , paddingEach { top = 84, left = 0, right = 0, bottom = 0 }
        ]
        [ el [ Font.size 24, Font.semiBold ] (text heading)
        , column [ spacing 8 ] (List.map (viewSideLink activeRoute) items)
        ]


viewSideLink : Route -> SideItem -> Element msg
viewSideLink activeRoute item =
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
                    if route == activeRoute then
                        styles.link.disabled

                    else
                        styles.link.enabled
            in
            link (Font.color colors.coral :: linkStyles)
                { label = text label
                , url = Routes.toPath route
                }

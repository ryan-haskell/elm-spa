module Layouts.Docs exposing (view)

import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Ui exposing (colors, styles)
import Utils.Spa as Spa


type SideItem
    = Heading String
    | Link ( String, Route )


links : List SideItem
links =
    [ Link ( "docs", routes.docs_top )
    , Heading "the cli"
    , Link ( "elm-spa init", routes.docs_dynamic_dynamic "elm-spa" "init" )
    , Link ( "elm-spa add", routes.docs_dynamic_dynamic "elm-spa" "add" )
    , Link ( "elm-spa build", routes.docs_dynamic_dynamic "elm-spa" "build" )
    ]


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    row [ width fill, height fill ]
        [ viewSidebar route links
        , column
            [ width fill
            , height fill
            , alignTop
            , spacing 32
            ]
            [ page
            , viewNextArticle route
            ]
        ]


viewNextArticle : Route -> Element msg
viewNextArticle route =
    (\link -> paragraph [ Font.size 20 ] [ el [ Font.semiBold ] <| text "next up: ", link ]) <|
        case nextArticle route links of
            Just ( label, r ) ->
                link (Font.color colors.coral :: styles.link.enabled)
                    { label = text label
                    , url = Routes.toPath r
                    }

            Nothing ->
                link (Font.color colors.coral :: styles.link.enabled)
                    { label = text "the guide"
                    , url = "/guide"
                    }


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


viewSidebar : Route -> List SideItem -> Element msg
viewSidebar activeRoute items =
    column
        [ alignTop
        , spacing 16
        , width (px 180)
        , paddingEach { top = 84, left = 0, right = 0, bottom = 0 }
        ]
        [ el [ Font.size 24, Font.semiBold ] (text "docs")
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

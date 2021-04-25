module Domain.Index exposing
    ( Index, decoder
    , Link, search
    , Section, sections
    )

{-|

@docs Index, decoder
@docs Link, search
@docs Section, sections

-}

import Dict exposing (Dict)
import Html exposing (Html)
import Json.Decode as Json
import Utils.String


type alias Index =
    List IndexedPage


decoder : Json.Decoder Index
decoder =
    let
        indexedPageDecoder : Json.Decoder IndexedPage
        indexedPageDecoder =
            Json.map2 IndexedPage
                (Json.field "url" Json.string)
                (Json.field "headers" (Json.dict Json.int))
    in
    Json.list indexedPageDecoder


type alias IndexedPage =
    { url : String
    , headers : Dict String Int
    }


type alias Link =
    { html : Html Never
    , label : String
    , url : String
    , level : Int
    }


terms : Index -> List ( String, String, Int )
terms =
    List.concatMap
        (\page ->
            page.headers
                |> Dict.toList
                |> List.map
                    (\( header, level ) ->
                        ( header
                        , page.url
                            ++ (if level == 1 then
                                    ""

                                else
                                    "#" ++ Utils.String.toId header
                               )
                        , level
                        )
                    )
        )


search : String -> Index -> List Link
search query index =
    index
        |> terms
        |> List.map
            (\( label, url, level ) ->
                { label = label
                , url = url
                , level = level
                , html = Utils.String.format query label
                }
            )
        |> List.filter (\link -> Utils.String.caseInsensitiveContains query link.label)



-- SECTIONS


type alias Section =
    { header : String
    , url : String
    , pages : List SectionLink
    }


type alias SectionLink =
    { label : String
    , url : String
    }


sections : Index -> List Section
sections index =
    let
        sectionOrder =
            [ "Guide"
            , "Examples"
            ]

        toLabelUrls =
            List.filterMap
                (\doc ->
                    doc.headers
                        |> Dict.filter (\_ level -> level == 1)
                        |> Dict.toList
                        |> List.head
                        |> Maybe.map (Tuple.first >> (\label -> { label = label, url = doc.url }))
                )

        topLevelLabelUrls : List { label : String, url : String }
        topLevelLabelUrls =
            let
                isOneLevelDeep doc =
                    List.length (String.split "/" doc.url) == 2
            in
            index
                |> List.filter isOneLevelDeep
                |> toLabelUrls

        toSection top children =
            { header = top.label
            , url = top.url
            , pages = children
            }
    in
    topLevelLabelUrls
        |> List.map
            (\top ->
                index
                    |> List.filter (.url >> (\url -> String.startsWith top.url url && url /= top.url))
                    |> toLabelUrls
                    |> List.sortBy .url
                    |> toSection top
            )
        |> List.sortBy
            (\section ->
                sectionOrder
                    |> List.indexedMap Tuple.pair
                    |> List.filter (Tuple.second >> (==) section.header)
                    |> List.map Tuple.first
                    |> List.head
                    |> Maybe.withDefault -1
            )

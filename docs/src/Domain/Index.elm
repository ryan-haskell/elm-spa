module Domain.Index exposing
    ( Index, decoder
    , Link, search
    )

{-|

@docs Index, decoder
@docs Link, search

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

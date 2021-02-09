module Utils.String exposing
    ( caseInsensitiveContains
    , format
    , toId
    )

import Html exposing (Html)


caseInsensitiveContains : String -> String -> Bool
caseInsensitiveContains sub word =
    String.contains (String.toLower sub) (String.toLower word)


toId : String -> String
toId =
    String.toLower
        >> String.words
        >> List.map (String.filter (\c -> c == '-' || Char.isAlphaNum c))
        >> String.join "-"


format : String -> String -> Html msg
format query original =
    original
        |> String.toLower
        |> String.split (String.toLower query)
        |> List.indexedMap Tuple.pair
        |> List.foldl
            (\( index, segment ) ( length, str ) ->
                let
                    nextLength =
                        length + String.length segment + String.length query
                in
                ( nextLength
                , str
                    ++ [ original
                            |> String.dropLeft length
                            |> String.left (String.length segment)
                            |> Html.text
                       ]
                    ++ (if nextLength > String.length original then
                            []

                        else
                            [ original
                                |> String.dropLeft (length + String.length segment)
                                |> String.left (String.length query)
                                |> Html.text
                                |> List.singleton
                                |> Html.strong []
                            ]
                       )
                )
            )
            ( 0, [] )
        |> Tuple.second
        |> Html.span []

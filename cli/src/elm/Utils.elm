module Utils exposing
    ( Items
    , addInMissingFolders
    , allSubsets
    )

import Dict exposing (Dict)
import List.Extra
import Set exposing (Set)


type alias Filepath =
    List String


type alias Items =
    { files : Set Filepath
    , folders : Set Filepath
    }


allSubsets : List (List comparable) -> List (List comparable)
allSubsets =
    List.concatMap
        (\list -> List.indexedMap (\i _ -> List.take (i + 1) list) list)
        >> List.Extra.unique


addInMissingFolders : Dict String Items -> Dict String Items
addInMissingFolders dict =
    let
        keys : List String
        keys =
            Dict.keys dict
                |> List.map (String.split ".")
                |> allSubsets
                |> List.map (String.join ".")

        splitOnDot : String -> Filepath
        splitOnDot str =
            if String.isEmpty str then
                []

            else
                String.split "." str

        oneLongerThan : Filepath -> Set Filepath
        oneLongerThan filepath =
            keys
                |> List.map splitOnDot
                |> List.filter (\dictFilepath -> List.length dictFilepath == List.length filepath + 1)
                |> Set.fromList
    in
    keys
        |> List.map
            (\key ->
                Dict.get key dict
                    |> Maybe.withDefault (Items Set.empty Set.empty)
                    |> (\items -> { items | folders = Set.union items.folders (oneLongerThan (splitOnDot key)) })
                    |> Tuple.pair key
            )
        |> Dict.fromList

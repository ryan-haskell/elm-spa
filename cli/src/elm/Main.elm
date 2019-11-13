module Main exposing (main)

import Dict exposing (Dict)
import File exposing (File)
import Json.Encode as Json
import Ports
import Set exposing (Set)


type alias Flags =
    List Filepath


type alias Filepath =
    List String


main : Program Flags () Never
main =
    Platform.worker
        { init = \json -> ( (), parse json )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }


parse : List Filepath -> Cmd msg
parse files =
    files
        |> List.foldl groupByFolder Dict.empty
        |> toDetails
        |> generate
            [ File.params
            , File.route
            ]
        |> Ports.sendFiles



-- UTILS


generate : List (a -> b) -> List a -> List b
generate fns value =
    List.map
        (\fn -> List.map fn value)
        fns
        |> List.concat


dropLast : List a -> List a
dropLast =
    List.reverse
        >> List.drop 1
        >> List.reverse


fileWithin : Filepath -> String
fileWithin =
    dropLast
        >> String.join "."


folderWithin : Filepath -> String
folderWithin =
    List.reverse
        >> List.drop 2
        >> List.reverse
        >> String.join "."


type alias Items =
    { files : Set Filepath
    , folders : Set Filepath
    }


groupByFolder :
    Filepath
    -> Dict String Items
    -> Dict String Items
groupByFolder filepath =
    Dict.update
        (fileWithin filepath)
        (Maybe.map
            (\entry -> { entry | files = Set.insert filepath entry.files })
            >> Maybe.withDefault
                { files = Set.singleton filepath
                , folders = Set.empty
                }
            >> Just
        )
        >> Dict.update
            (folderWithin filepath)
            (Maybe.map
                (\entry -> { entry | folders = Set.insert (dropLast filepath) entry.folders })
                >> Maybe.withDefault
                    { folders = Set.singleton (dropLast filepath)
                    , files = Set.empty
                    }
                >> (\entry -> { entry | folders = Set.filter ((/=) []) entry.folders })
                >> Just
            )


toDetails :
    Dict String Items
    -> List File.Details
toDetails dict =
    Dict.toList dict
        |> List.map
            (\( moduleName, { files, folders } ) ->
                { moduleName = moduleName
                , folders = Set.toList folders
                , files = Set.toList files
                }
            )

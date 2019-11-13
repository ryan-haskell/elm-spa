module Main exposing (main)

import Dict exposing (Dict)
import File exposing (File)
import Json.Encode as Json
import Ports


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
parse =
    List.foldl groupByFolder Dict.empty
        >> toGroupedFiles
        >> generate
            [ File.params
            , File.route
            ]
        >> Ports.sendFiles



-- UTILS


generate : List (a -> b) -> List a -> List b
generate fns value =
    List.map
        (\fn -> List.map fn value)
        fns
        |> List.concat


folderOf : Filepath -> String
folderOf =
    List.reverse
        >> List.drop 1
        >> List.reverse
        >> String.join "."


groupByFolder :
    Filepath
    -> Dict String (List Filepath)
    -> Dict String (List Filepath)
groupByFolder items =
    Dict.update
        (folderOf items)
        (Maybe.map ((::) items)
            >> Maybe.withDefault [ items ]
            >> Just
        )


toGroupedFiles :
    Dict String (List Filepath)
    -> List File.GroupedFiles
toGroupedFiles dict =
    Dict.toList dict
        |> List.map
            (\( moduleName, paths ) ->
                let
                    isFolder path =
                        Dict.keys dict
                            |> List.map (String.split ".")
                            |> List.any ((==) path)

                    ( folders, files ) =
                        List.partition isFolder paths
                in
                { moduleName = moduleName
                , folders = folders
                , files = files
                , paths = paths
                }
            )

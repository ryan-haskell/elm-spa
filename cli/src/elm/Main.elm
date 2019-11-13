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



-- ACTUAL CODE


parse : List Filepath -> Cmd msg
parse =
    List.foldl groupByFolder Dict.empty
        >> (\dict ->
                [ paramsFiles dict
                ]
           )
        >> List.concat
        >> Ports.sendFiles


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


paramsFiles :
    Dict String (List Filepath)
    -> List File
paramsFiles =
    Dict.toList
        >> List.map
            (\( moduleName, paths ) ->
                { filepath =
                    String.split "." moduleName ++ [ "Params" ]
                , contents =
                    File.params
                        { moduleName = moduleName
                        , paths = paths
                        }
                }
            )

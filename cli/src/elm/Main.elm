module Main exposing (main)

import Dict exposing (Dict)
import File exposing (File)
import Json.Decode as D exposing (Decoder)
import Json.Encode as Json
import Ports
import Set exposing (Set)


type alias Flags =
    { command : String
    , data : Json.Value
    }


type Args
    = BuildArgs BuildConfig
    | AddArgs AddConfig


type alias BuildConfig =
    { paths : List Filepath
    }


type alias AddConfig =
    { ui : String
    , pageType : PageType
    , moduleName : List String
    }


type PageType
    = Static
    | Sandbox
    | Element
    | Component


argsDecoder : String -> Decoder Args
argsDecoder command =
    case command of
        "build" ->
            D.map BuildArgs <|
                D.map BuildConfig
                    (D.list (D.list D.string))

        _ ->
            D.fail <| "Couldn't recognize command: " ++ command


type alias Filepath =
    List String


main : Program Flags () Never
main =
    Platform.worker
        { init = \flags -> ( (), handle flags )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }


handle : Flags -> Cmd msg
handle flags =
    D.decodeValue
        (argsDecoder flags.command)
        flags.data
        |> (\result ->
                case result of
                    Ok args ->
                        case args of
                            BuildArgs config ->
                                build config

                            AddArgs config ->
                                add config

                    Err error ->
                        case error of
                            D.Failure reason _ ->
                                Ports.error reason

                            _ ->
                                Cmd.none
           )


build : BuildConfig -> Cmd msg
build { paths } =
    List.concat
        [ [ File [ "Routes" ] (File.routes paths) ]
        , paths
            |> List.foldl groupByFolder Dict.empty
            |> toDetails
            |> generate
                [ File.params
                , File.route
                , File.pages
                ]
        ]
        |> Ports.createFiles


add : AddConfig -> Cmd msg
add config =
    Cmd.none



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

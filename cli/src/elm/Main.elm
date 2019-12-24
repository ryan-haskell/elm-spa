module Main exposing (main)

import Add
import Dict exposing (Dict)
import File exposing (File)
import Json.Decode as D exposing (Decoder)
import Json.Encode as Json
import Ports
import Set exposing (Set)
import Templates.Layout


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
    , pageType : Add.PageType
    , modulePath : List String
    , layoutPaths : List Filepath
    }


argsDecoder : String -> Decoder Args
argsDecoder command =
    case command of
        "add" ->
            D.map AddArgs <|
                D.map4 AddConfig
                    (D.field "ui" D.string)
                    (D.field "pageType" Add.pageTypeDecoder)
                    (D.field "moduleName" Add.modulePathDecoder)
                    (D.field "layoutPaths" (D.list (D.list D.string)))

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
            |> Debug.log "grouped"
            |> toDetails
            |> (\items ->
                    let
                        itemsWithFiles : List File.Details
                        itemsWithFiles =
                            List.filter
                                (.files >> List.isEmpty >> not)
                                items

                        shouldImportParams : String -> Bool
                        shouldImportParams filepath =
                            List.member filepath
                                (List.map .moduleName itemsWithFiles)
                    in
                    List.concat
                        [ List.map File.params itemsWithFiles
                        , List.map (File.route { shouldImportParams = shouldImportParams }) items
                        , List.map (File.pages { shouldImportParams = shouldImportParams }) items
                        ]
               )
        ]
        |> List.map (\file -> { file | filepath = List.append [ "elm-stuff", ".elm-spa", "Generated" ] file.filepath })
        |> Ports.createFiles


add : AddConfig -> Cmd msg
add config =
    Ports.createFiles <|
        List.concat
            [ layoutsToCreate
                { path = config.modulePath
                , existingLayouts = config.layoutPaths
                }
                |> List.map
                    (\path ->
                        { filepath = List.append [ "src", "Layouts" ] path
                        , contents = Templates.Layout.contents { ui = config.ui, modulePath = path }
                        }
                    )
            , [ { filepath = List.append [ "src", "Pages" ] config.modulePath
                , contents =
                    Add.generate
                        config.pageType
                        { modulePath = config.modulePath
                        , ui = config.ui
                        }
                }
              ]
            ]



-- UTILS


layoutsToCreate : { path : Filepath, existingLayouts : List Filepath } -> List Filepath
layoutsToCreate { path, existingLayouts } =
    let
        subLists : List a -> List (List a)
        subLists list =
            list
                |> List.repeat (List.length list - 1)
                |> List.indexedMap (\i -> List.take (1 + i))
    in
    subLists path
        |> List.filter (\list -> not (List.member list existingLayouts))


generate : List (a -> Maybe b) -> List a -> List b
generate fns value =
    List.map
        (\fn -> List.filterMap fn value)
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
    [ ( ""
      , { files = Set.fromList [ [ "NotFound" ], [ "Top" ] ]
        , folders = Set.fromList [ [ "Authors" ] ]
        }
      )
    , ( "Authors"
      , { files = Set.fromList []
        , folders = Set.fromList [ [ "Authors", "Dynamic" ] ]
        }
      )
    , ( "Authors.Dynamic"
      , { files = Set.fromList []
        , folders = Set.fromList [ [ "Authors", "Dynamic", "Posts" ] ]
        }
      )
    , ( "Authors.Dynamic.Posts"
      , { files = Set.fromList [ [ "Authors", "Dynamic", "Posts", "Dynamic" ] ]
        , folders = Set.fromList []
        }
      )
    ]
        |> List.map
            (\( moduleName, { files, folders } ) ->
                { moduleName = moduleName
                , folders = Set.toList folders
                , files = Set.toList files
                }
            )

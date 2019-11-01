port module Main exposing (main)

import Item exposing (Item)
import Json.Decode as D exposing (Decoder)
import Templates.Pages
import Templates.Route


port toJs : List NewFile -> Cmd msg


type alias NewFile =
    { filepathSegments : List String
    , contents : String
    }



-- PROGRAM


main : Program D.Value () msg
main =
    Platform.worker
        { init = \json -> ( (), toJs <| parse json )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }


parse : D.Value -> List NewFile
parse =
    D.decodeValue decoder >> Result.withDefault []



-- DECODER


decoder : Decoder (List NewFile)
decoder =
    commandDecoder
        |> D.map
            (\command ->
                case command of
                    Add info ->
                        addCommand info

                    Build info ->
                        buildCommand info
            )


buildCommand : BuildInfo -> List NewFile
buildCommand { items, options } =
    items
        |> toFileInfo []
        |> fromData options


addCommand : AddInfo -> List NewFile
addCommand { page, path } =
    []


type Command
    = Build BuildInfo
    | Add AddInfo


type alias BuildInfo =
    { items : List Item
    , options : Options
    }


type alias Options =
    { ui : String
    }


type alias AddInfo =
    { page : String
    , path : List String
    }


commandDecoder : Decoder Command
commandDecoder =
    D.field "command" D.string
        |> D.andThen fromCommand


fromCommand : String -> Decoder Command
fromCommand command =
    case command of
        "build" ->
            D.map Build <|
                D.map2 BuildInfo
                    (D.field "folders" (D.list Item.decoder))
                    (D.field "options" optionsDecoder)

        "add" ->
            D.map Add <|
                D.map2 AddInfo
                    (D.field "page" D.string)
                    (D.field "path" (D.list D.string))

        _ ->
            D.fail <| "Don't recognize command: " ++ command


optionsDecoder : Decoder Options
optionsDecoder =
    D.map Options
        (D.field "ui" D.string)


type alias FileInfo =
    { path : List String
    , items : List Item
    }


toFileInfo : List String -> List Item -> List FileInfo
toFileInfo path items =
    List.foldl
        (\folder infos ->
            infos ++ toFileInfo (path ++ [ folder.name ]) folder.children
        )
        [ { path = path, items = items }
        ]
        (Item.folders items)


fromData : Options -> List FileInfo -> List NewFile
fromData options fileInfos =
    List.concat
        [ List.map routeFile fileInfos
        , List.map (pageFile options) fileInfos
        ]


pageFile : Options -> FileInfo -> NewFile
pageFile { ui } { path, items } =
    { filepathSegments = segments "Pages" path
    , contents = Templates.Pages.contents ui items path
    }


routeFile : FileInfo -> NewFile
routeFile { path, items } =
    { filepathSegments = segments "Route" path
    , contents = Templates.Route.contents items path
    }


segments : String -> List String -> List String
segments prefix path =
    "Generated"
        :: (if List.isEmpty path then
                [ prefix ++ ".elm" ]

            else
                prefix :: appendToLast ".elm" path
           )


appendToLast : String -> List String -> List String
appendToLast str list =
    let
        lastIndex =
            List.length list - 1
    in
    List.indexedMap
        (\i value ->
            if i == lastIndex then
                value ++ str

            else
                value
        )
        list

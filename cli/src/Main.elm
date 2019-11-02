port module Main exposing (main)

import Item exposing (Item)
import Json.Decode as D exposing (Decoder)
import Templates.Pages
import Templates.Pages.Component as Component
import Templates.Pages.Element as Element
import Templates.Pages.Layout as Layout
import Templates.Pages.Sandbox as Sandbox
import Templates.Pages.Static as Static
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
buildCommand { pages, options } =
    pages
        |> toFileInfo []
        |> fromData options


addCommand : AddInfo -> List NewFile
addCommand { page, path, layouts } =
    let
        existingLayoutPaths : List (List String)
        existingLayoutPaths =
            layouts
                |> List.map toLayoutPaths
                |> List.concat

        newPagePath : List String
        newPagePath =
            "Pages" :: appendToLast ".elm" path

        subsets : List a -> List (List a)
        subsets list =
            list
                |> List.indexedMap (\i _ -> List.take i list)
                |> List.drop 1

        layoutsToCreate : List NewFile
        layoutsToCreate =
            -- TODO: should only need to create at most one layout
            path
                |> subsets
                |> List.filter (\list -> not (List.member list existingLayoutPaths))
                |> List.map
                    (\path_ ->
                        { filepathSegments = "Layouts" :: appendToLast ".elm" path_
                        , contents = Layout.contents { path = path_ }
                        }
                    )
    in
    case page of
        Static ->
            { filepathSegments = newPagePath
            , contents = Static.contents { path = path }
            }
                :: layoutsToCreate

        Sandbox ->
            { filepathSegments = newPagePath
            , contents = Sandbox.contents { path = path }
            }
                :: layoutsToCreate

        Element ->
            { filepathSegments = newPagePath
            , contents = Element.contents { path = path }
            }
                :: layoutsToCreate

        Component ->
            { filepathSegments = newPagePath
            , contents = Component.contents { path = path }
            }
                :: layoutsToCreate


toLayoutPaths : Item -> List (List String)
toLayoutPaths item =
    case item of
        Item.File_ { name } ->
            [ [ name ]
            ]

        Item.Folder_ { name, children } ->
            children
                |> List.map toLayoutPaths
                |> List.concat
                |> List.map (\tail -> name :: tail)


type Command
    = Build BuildInfo
    | Add AddInfo


type alias BuildInfo =
    { pages : List Item
    , options : Options
    }


type alias Options =
    { ui : String
    }


type alias AddInfo =
    { page : PageType
    , path : List String
    , layouts : List Item
    }


type PageType
    = Static
    | Sandbox
    | Element
    | Component


pageTypeDecoder : Decoder PageType
pageTypeDecoder =
    D.string
        |> D.andThen
            (\str ->
                case str of
                    "static" ->
                        D.succeed Static

                    "sandbox" ->
                        D.succeed Sandbox

                    "element" ->
                        D.succeed Element

                    "component" ->
                        D.succeed Component

                    _ ->
                        D.fail (str ++ "is not a page type.")
            )


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
                    (D.field "pages" (D.list Item.decoder))
                    (D.field "options" optionsDecoder)

        "add" ->
            D.map Add <|
                D.map3 AddInfo
                    (D.field "page" pageTypeDecoder)
                    (D.field "path" (D.list D.string))
                    (D.field "layouts" (D.list Item.decoder))

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

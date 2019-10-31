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
    D.map fromFlags flagsDecoder


fromFlags : Flags -> Decoder (List NewFile)
fromFlags { items, options } =
     items
         |> D.map (toFileInfo [])
         |> D.map (fromData options)


type alias Flags =
    { items : List Item
    , options : Options
    }


type alias Options =
    { ui : String
    }


flagsDecoder : Decoder Flags
flagsDecoder =
    D.map2 Flags
        (D.field "folders" (D.list Item.decoder))
        (D.field "options" optionsDecoder)


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

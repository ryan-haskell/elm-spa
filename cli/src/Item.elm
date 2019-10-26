module Item exposing
    ( Item
    , children
    , decoder
    , files
    , folders
    , isFile
    , isFolder
    , name
    )

import Json.Decode as D exposing (Decoder)


type Item
    = File_ File
    | Folder_ Folder


type alias File =
    { name : String
    }


type alias Folder =
    { name : String
    , children : List Item
    }


isFile : Item -> Bool
isFile item =
    case item of
        File_ _ ->
            True

        Folder_ _ ->
            False


isFolder : Item -> Bool
isFolder item =
    case item of
        File_ _ ->
            False

        Folder_ _ ->
            True


name : Item -> String
name item =
    case item of
        File_ file ->
            file.name

        Folder_ folder ->
            folder.name


children : Item -> List Item
children item =
    case item of
        File_ _ ->
            []

        Folder_ folder ->
            folder.children


files : List Item -> List File
files =
    List.filterMap
        (\item ->
            case item of
                File_ file ->
                    Just file

                Folder_ _ ->
                    Nothing
        )


folders : List Item -> List Folder
folders =
    List.filterMap
        (\item ->
            case item of
                File_ _ ->
                    Nothing

                Folder_ folder ->
                    Just folder
        )



-- JSON


decoder : Decoder Item
decoder =
    D.field "type" D.string
        |> D.andThen
            (\type_ ->
                case type_ of
                    "file" ->
                        fileDecoder

                    "folder" ->
                        folderDecoder

                    _ ->
                        D.fail ("I don't recognize " ++ type_)
            )


fileDecoder : Decoder Item
fileDecoder =
    D.map File_ <|
        D.map File
            (D.field "name" D.string |> D.map (String.dropRight 4))


folderDecoder : Decoder Item
folderDecoder =
    D.map Folder_ <|
        D.map2 Folder
            (D.field "name" D.string)
            (D.field "children" (D.list decoder))

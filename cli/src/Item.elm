module Item exposing
    ( Item
    , children
    , decoder
    , isFile
    , isFolder
    , name
    )

import Json.Decode as D exposing (Decoder)


type Item
    = File String
    | Folder String (List Item)


isFile : Item -> Bool
isFile item =
    case item of
        File _ ->
            True

        Folder _ _ ->
            False


isFolder : Item -> Bool
isFolder item =
    case item of
        File _ ->
            False

        Folder _ _ ->
            True


name : Item -> String
name item =
    case item of
        File name_ ->
            name_

        Folder name_ _ ->
            name_


children : Item -> List Item
children item =
    case item of
        File _ ->
            []

        Folder _ children_ ->
            children_



-- JSON


decoder : Decoder Item
decoder =
    D.field "type" D.string
        |> D.andThen
            (\type_ ->
                case type_ of
                    "file" ->
                        file

                    "folder" ->
                        folder

                    _ ->
                        D.fail ("I don't recognize " ++ type_)
            )


file : Decoder Item
file =
    D.map File
        (D.field "name" D.string)


folder : Decoder Item
folder =
    D.map2 Folder
        (D.field "name" D.string)
        (D.field "children" (D.list decoder))

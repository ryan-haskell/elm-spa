module Internals.Path exposing
    ( Path
    , Piece
    , dynamic
    , static
    , within
    )


type alias Path =
    List Piece


type Piece
    = Static String
    | Dynamic


static : String -> Piece
static =
    Static


dynamic : Piece
dynamic =
    Dynamic


within : List String -> List Piece -> Bool
within strings pieces =
    List.length pieces
        <= List.length strings
        && (List.map2
                matches
                strings
                pieces
                |> List.all ((==) True)
           )


matches : String -> Piece -> Bool
matches str piece =
    case piece of
        Static value ->
            str == value

        Dynamic ->
            True

module Internals.Pattern exposing
    ( Pattern
    , Piece
    , dynamic
    , matches
    , static
    )


type alias Pattern =
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


matches : List String -> List Piece -> Bool
matches strings pieces =
    List.length pieces
        <= List.length strings
        && (List.map2
                comparePiece
                strings
                pieces
                |> List.all ((==) True)
           )


comparePiece : String -> Piece -> Bool
comparePiece str piece =
    case piece of
        Static xyz ->
            str == xyz

        Dynamic ->
            True

module App.Pattern exposing
    ( Pattern
    , dynamic
    , static
    )

import Internals.Pattern as Internals


type alias Pattern =
    Internals.Pattern


static : String -> Internals.Piece
static =
    Internals.static


dynamic : Internals.Piece
dynamic =
    Internals.dynamic

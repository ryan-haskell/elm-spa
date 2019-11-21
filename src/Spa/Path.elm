module Spa.Path exposing
    ( Path
    , dynamic
    , static
    )

import Internals.Path as Internals


type alias Path =
    Internals.Path


static : String -> Internals.Piece
static =
    Internals.static


dynamic : Internals.Piece
dynamic =
    Internals.dynamic

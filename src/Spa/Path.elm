module Spa.Path exposing
    ( Path
    , static, dynamic
    )

{-|


## Modify transitions at different routes!

If you're using the [CLI companion tool](https://github.com/ryannhg/elm-spa/tree/master/cli),
these are **automatically generated**.

(So feel free to ignore these docs!)

If you're doing things by hand, this documentation might be helpful!

@docs Path

@docs static, dynamic

-}

import Internals.Path as Internals


{-| a `List` of path segments that you use with `Spa.Transition`

    transitions : Spa.Transitions (Element msg)
    transitions =
        { layout = Transition.none
        , page = Transition.none
        , pages =
            [ -- applies fade to all pages under `/guide/*`
              { path = [ static "guide" ]
              , transition = Transition.fadeElmUi 300
              }
            ]
        }

-}
type alias Path =
    List Internals.Piece


{-| A static segment of a path.

    [ static "docs" ]
    -- /docs

    [ static "docs", static "intro" ]
    -- /docs/intro

-}
static : String -> Internals.Piece
static =
    Internals.static


{-| A dynamic segment of a path.

    [ static "docs", dynamic ]
    -- /docs/welcome
    -- /docs/hello
    -- /docs/hooray

    [ static "docs", dynamic, static "intro" ]
    -- /docs/welcome/intro
    -- /docs/hello/intro
    -- /docs/hooray/intro

-}
dynamic : Internals.Piece
dynamic =
    Internals.dynamic

module Internals.Transitionable exposing
    ( Transitionable(..)
    , isFirstLoad
    , layoutOpacity
    , map
    , pageOpacity
    , unwrap
    )


type Transitionable a
    = FirstLoad a
    | Loading a
    | Loaded a


isFirstLoad : Transitionable a -> Bool
isFirstLoad transitionable =
    case transitionable of
        FirstLoad _ ->
            True

        _ ->
            False


unwrap : Transitionable a -> a
unwrap transitionable =
    case transitionable of
        FirstLoad a ->
            a

        Loading a ->
            a

        Loaded a ->
            a


map : (a -> b) -> Transitionable a -> Transitionable b
map fn transitionable =
    case transitionable of
        FirstLoad a ->
            FirstLoad (fn a)

        Loading a ->
            Loading (fn a)

        Loaded a ->
            Loaded (fn a)


layoutOpacity : Transitionable a -> String
layoutOpacity transitionable =
    case transitionable of
        FirstLoad _ ->
            "0"

        Loading _ ->
            "1"

        Loaded _ ->
            "1"


pageOpacity : Transitionable a -> String
pageOpacity transitionable =
    case transitionable of
        FirstLoad _ ->
            "0"

        Loading _ ->
            "0"

        Loaded _ ->
            "1"

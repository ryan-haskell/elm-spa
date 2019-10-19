module Internals.Transitionable exposing
    ( Transitionable(..)
    , begin
    , complete
    , unwrap
    )


type Transitionable a
    = Ready a
    | Transitioning a
    | Complete a


unwrap : Transitionable a -> a
unwrap transitionable =
    case transitionable of
        Ready value ->
            value

        Transitioning value ->
            value

        Complete value ->
            value


begin : Transitionable a -> Transitionable a
begin =
    unwrap >> Transitioning


complete : Transitionable a -> Transitionable a
complete =
    unwrap >> Complete

module Internals.Layout exposing (Layout)

import Html exposing (Html)
import Internals.Transition exposing (Transition)


type alias Layout msg =
    { view : { page : Html msg } -> Html msg
    , transition : Transition (Html msg)
    }

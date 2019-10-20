module Internals.Layout exposing (Layout)

import Html exposing (Html)


type alias Layout msg =
    { view : { page : Html msg } -> Html msg
    }

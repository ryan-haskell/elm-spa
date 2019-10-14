module Vanilla.Static exposing (main, view)

import Html exposing (..)


main : Html msg
main =
    view


view : Html msg
view =
    div []
        [ h1 [] [ text "Homepage" ]
        , p [] [ text "How exciting!" ]
        ]

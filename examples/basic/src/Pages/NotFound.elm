module Pages.NotFound exposing
    ( title
    , view
    )

import Html exposing (..)


title : String
title =
    "Not found."


view : Html Never
view =
    div []
        [ h1 [] [ text "Page not found!" ]
        , p []
            [ text "Is this space? Am I in "
            , em [] [ text "space?" ]
            ]
        ]

module Pages.Homepage exposing
    ( title
    , view
    )

import Html exposing (..)


title : String
title =
    "Homepage"


view : Html Never
view =
    div []
        [ h1 [] [ text "Homepage!" ]
        , p [] [ text "It's boring, but it works!" ]
        ]

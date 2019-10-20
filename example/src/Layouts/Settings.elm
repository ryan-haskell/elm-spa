module Layouts.Settings exposing (layout)

import Application
import Html exposing (..)


layout : Application.Layout msg
layout =
    { view = view
    }


view : { page : Html msg } -> Html msg
view { page } =
    div []
        [ h1 [] [ text "Settings" ]
        , page
        ]

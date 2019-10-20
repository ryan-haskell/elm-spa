module Layouts.Main exposing (layout)

import Application
import Components.Navbar
import Html exposing (..)
import Html.Attributes as Attr


layout : Application.Layout msg
layout =
    { view = view
    }


view : { page : Html msg } -> Html msg
view { page } =
    div
        [ Attr.style "margin" "2rem auto"
        , Attr.style "max-width" "720px"
        ]
        [ Components.Navbar.view
        , page
        ]

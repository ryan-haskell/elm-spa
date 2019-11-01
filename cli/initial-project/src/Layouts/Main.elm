module Layouts.Main exposing (view)

import Components.Navbar
import Global
import Html exposing (..)
import Html.Attributes as Attr


view :
    { page : Html msg
    , global : Global.Model
    }
    -> Html msg
view { page } =
    div
        [ Attr.class "layout"
        , Attr.style "margin" "0 auto"
        , Attr.style "max-width" "60ch"
        , Attr.style "padding" "2rem 1rem"
        , Attr.style "font-family" "sans-serif"
        ]
        [ Components.Navbar.view
        , page
        ]

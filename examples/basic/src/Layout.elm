module Layout exposing (view)

import Components.Navbar
import Html exposing (..)
import Html.Attributes as Attr


view : { page : Html msg } -> Html msg
view { page } =
    div
        [ Attr.style "margin" "2rem auto"
        , Attr.style "max-width" "720px"
        ]
        [ Components.Navbar.view
        , page
        ]

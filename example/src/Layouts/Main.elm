module Layouts.Main exposing
    ( transition
    , view
    )

import Application
import Components.Navbar
import Global
import Html exposing (..)
import Html.Attributes as Attr


transition : Application.Transition (Html msg)
transition =
    Application.fade 200


view :
    { page : Html msg
    , global : Global.Model
    }
    -> Html msg
view { page } =
    div
        [ Attr.style "margin" "2rem auto"
        , Attr.style "max-width" "720px"
        ]
        [ Components.Navbar.view
        , div [ Attr.style "margin-top" "2rem" ] [ page ]
        ]

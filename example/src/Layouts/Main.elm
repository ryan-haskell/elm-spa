module Layouts.Main exposing (layout)

import Application.Page as Page
import Application.Transition as Transition
import Components.Navbar
import Global
import Html exposing (..)
import Html.Attributes as Attr


layout : Page.LayoutOptions Global.Model msg
layout =
    { transition = Transition.fade 200
    , view = view
    }


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

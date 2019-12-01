module Layouts.Docs exposing (view)

import Components.Sidebar as Sidebar
import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Ui exposing (colors, styles)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    row [ width fill ]
        [ Sidebar.view route
        , el [ width fill, alignTop ] page
        ]

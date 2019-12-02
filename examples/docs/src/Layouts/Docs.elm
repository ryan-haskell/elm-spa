module Layouts.Docs exposing (view)

import Components.Sidebar as Sidebar
import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Global
import Ui exposing (colors, styles)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page, route, global } =
    case global.device of
        Global.Mobile ->
            column [ width fill ]
                [ page
                , Sidebar.view route
                ]

        Global.Desktop ->
            row [ width fill ]
                [ Sidebar.view route
                , el [ width fill, alignTop ] page
                ]

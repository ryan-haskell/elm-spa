module Layouts.Docs exposing (view)

import Components.Sidebar as Sidebar
import Element exposing (..)
import Global
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page, route, global } =
    case global.device of
        Global.Mobile ->
            column [ width fill ]
                [ page
                , Sidebar.viewDocLinks route
                ]

        Global.Desktop ->
            row [ width fill ]
                [ Sidebar.viewDocLinks route
                , el [ width fill, alignTop ] page
                ]

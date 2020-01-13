module Layouts.Guide exposing (view)

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
                , Sidebar.viewGuideLinks route
                ]

        Global.Desktop ->
            row [ width fill ]
                [ Sidebar.viewGuideLinks route
                , el [ width fill, alignTop ] page
                ]

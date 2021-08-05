module Pages.Settings.General exposing (layout, view)

import Gen.Layouts
import Html
import View exposing (View)


layout : Gen.Layouts.Layout
layout =
    Gen.Layouts.Sidebar__Header


view : View msg
view =
    { title = "General Settings"
    , body = [ Html.text "This is the general settings page." ]
    }

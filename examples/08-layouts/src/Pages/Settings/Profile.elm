module Pages.Settings.Profile exposing (layout, view)

import Gen.Layouts
import Html
import View exposing (View)


layout : Gen.Layouts.Layout
layout =
    Gen.Layouts.Sidebar__Header


view : View msg
view =
    { title = "Profile Settings"
    , body = [ Html.text "This is the profile settings page." ]
    }

module Pages.Home_ exposing (layout, view)

import Gen.Layouts
import View exposing (View)


layout : Gen.Layouts.Layout
layout =
    Gen.Layouts.Sidebar


view : View msg
view =
    View.placeholder "Dashboard"

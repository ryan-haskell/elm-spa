module Layouts.Guide.Dynamic exposing (view)

import Element exposing (..)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page } =
    page

module Layouts.Users exposing (view)

import Global
import Html exposing (Html)


view : { page : Html msg, global : Global.Model } -> Html msg
view { page } =
    page

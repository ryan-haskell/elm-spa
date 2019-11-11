module Layouts.Guide.Dynamic.Dynamic exposing (view)

import Element exposing (..)
import Global


type alias Context msg =
    { page : Element msg
    , global : Global.Model
    , toMsg : Global.Msg -> msg
    }


view : Context msg -> Element msg
view { page } =
    page

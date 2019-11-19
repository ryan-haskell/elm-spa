module Layouts.Guide.Dynamic exposing (transition, view)

import App.Transition as Transition exposing (Transition)
import Element exposing (..)
import Global


transition : Transition (Element msg)
transition =
    Transition.optOut


type alias Context msg =
    { page : Element msg
    , global : Global.Model
    , toMsg : Global.Msg -> msg
    }


view : Context msg -> Element msg
view { page } =
    page

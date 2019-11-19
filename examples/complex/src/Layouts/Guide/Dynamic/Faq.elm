module Layouts.Guide.Dynamic.Faq exposing (transition, view)

import App.Transition as Transition exposing (Transition)
import Element exposing (..)
import Global


type alias Context msg =
    { page : Element msg
    , global : Global.Model
    , toMsg : Global.Msg -> msg
    }


transition : Transition (Element msg)
transition =
    Transition.optOut


view : Context msg -> Element msg
view { page } =
    page

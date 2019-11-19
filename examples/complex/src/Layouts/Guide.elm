module Layouts.Guide exposing (transition, view)

import App.Transition as Transition exposing (Transition)
import Components.Styles as Styles
import Element exposing (..)
import Global


type alias Context msg =
    { page : Element msg
    , global : Global.Model
    , toMsg : Global.Msg -> msg
    }


transition : Transition (Element msg)
transition =
    Transition.fadeUi 3000


view : Context msg -> Element msg
view { page } =
    column
        [ width fill
        , spacing -128
        ]
        [ page
        , el [ centerX ] <|
            link Styles.link { label = text "back to guide", url = "/guide" }
        ]

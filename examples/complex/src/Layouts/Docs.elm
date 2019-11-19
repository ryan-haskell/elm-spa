module Layouts.Docs exposing (transition, view)

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
    Transition.fadeUi 200


view : Context msg -> Element msg
view { page } =
    column [ width fill ]
        [ row [ spacing 16 ]
            [ link [] { label = text "apples", url = "/docs/apples" }
            , link [] { label = text "bananas", url = "/docs/bananas" }
            ]
        , page
        ]

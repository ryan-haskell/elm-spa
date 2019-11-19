module App.Transition exposing
    ( Transition
    , optOut, none, fadeHtml, fadeUi
    )

{-|

@docs Transition
@docs optOut, none, fadeHtml, fadeUi

-}

import Element exposing (Element)
import Html exposing (Html)
import Internals.Transition


type alias Transition ui_msg =
    Internals.Transition.Transition ui_msg



-- TRANSITIONS


optOut : Transition ui_msg
optOut =
    Internals.Transition.optOut


none : Transition ui_msg
none =
    Internals.Transition.none


fadeHtml : Int -> Transition (Html msg)
fadeHtml =
    Internals.Transition.fadeHtml


fadeUi : Int -> Transition (Element msg)
fadeUi =
    Internals.Transition.fadeUi

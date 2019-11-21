module Spa.Transition exposing
    ( Transition
    , none, fadeHtml, fadeUi, custom
    )

{-|

@docs Transition
@docs none, fadeHtml, fadeUi, custom

-}

import Element exposing (Element)
import Html exposing (Html)
import Internals.Transition


type alias Transition ui_msg =
    Internals.Transition.Transition ui_msg



-- TRANSITIONS


none : Transition ui_msg
none =
    Internals.Transition.none


fadeHtml : Int -> Transition (Html msg)
fadeHtml =
    Internals.Transition.fadeHtml


fadeUi : Int -> Transition (Element msg)
fadeUi =
    Internals.Transition.fadeUi


custom :
    { speed : Int
    , invisible : View ui_msg
    , visible : View ui_msg
    }
    -> Transition ui_msg
custom =
    Internals.Transition.custom


type alias View ui_msg =
    ui_msg -> ui_msg

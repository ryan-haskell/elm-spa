module Transitions exposing (transitions)

import Spa.Transition as Transition
import Utils.Spa as Spa


transitions : Spa.Transitions msg
transitions =
    { layout = Transition.none
    , page = Transition.fadeElmUi 300
    , pages = []
    }

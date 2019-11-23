module Transitions exposing (transitions)

import Spa.Transition as Transition
import Utils.Spa as Spa


transitions : Spa.Transitions msg
transitions =
    { layout = Transition.fadeHtml 500
    , page = Transition.fadeHtml 300
    , pages = []
    }

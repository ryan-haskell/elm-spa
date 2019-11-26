module Transitions exposing (transitions)

import Element exposing (..)
import Generated.Guide.Pages as Guide
import Spa.Transition as Transition
import Ui
import Utils.Spa as Spa


transitions : Spa.Transitions msg
transitions =
    { layout = Transition.fadeElmUi 500
    , page = Transition.fadeElmUi 300
    , pages =
        [ { path = Guide.path
          , transition = slideFromNav 200
          }
        ]
    }


slideFromNav : Int -> Transition.Transition (Element msg)
slideFromNav duration =
    Transition.custom
        { duration = duration
        , invisible =
            el
                [ alpha 0
                , width fill
                , height fill
                , Ui.transition
                    { duration = 200
                    , props = [ "opacity", "transform" ]
                    }
                ]
        , visible =
            el
                [ alpha 1
                , width fill
                , height fill
                , Ui.transition
                    { duration = 200
                    , props = [ "opacity", "transform" ]
                    }
                ]
        }

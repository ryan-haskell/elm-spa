module Transitions exposing (transitions)

import Element exposing (..)
import Generated.Docs.Pages as Docs
import Generated.Guide.Pages as Guide
import Spa.Path exposing (static)
import Spa.Transition as Transition
import Ui
import Utils.Spa as Spa


transitions : Spa.Transitions msg
transitions =
    { layout = Transition.fadeElmUi 500
    , page = Transition.fadeElmUi 300
    , pages =
        [ { path = Guide.path
          , transition = Transition.fadeElmUi 300
          }
        , { path = Docs.path
          , transition = Transition.none
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
                , moveUp 32
                , height fill
                , Ui.transition
                    { duration = duration
                    , props = [ "opacity", "transform" ]
                    }
                ]
        , visible =
            el
                [ alpha 1
                , width fill
                , height fill
                , Ui.transition
                    { duration = duration
                    , props = [ "opacity", "transform" ]
                    }
                ]
        }

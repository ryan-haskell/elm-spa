module Transitions exposing (transitions)

import Utils.Styles as Styles
import Element exposing (..)
import Generated.Docs.Pages as Docs
import Spa.Transition as Transition exposing (Transition)


transitions : Transition.Transitions (Element msg)
transitions =
    { layout = Transition.fadeUi 300
    , page = Transition.fadeUi 300
    , pages =
        [ { path = Docs.path
          , transition = batmanNewspaper 600
          }
        ]
    }



-- MAKE YOUR OWN!


batmanNewspaper : Int -> Transition (Element msg)
batmanNewspaper duration =
    Transition.custom
        { duration = duration
        , invisible =
            \page ->
                el
                    [ alpha 0
                    , width fill
                    , rotate (4 * pi)
                    , scale 0
                    , Styles.transition
                        { property = "all"
                        , duration = duration
                        }
                    ]
                    page
        , visible =
            \page ->
                el
                    [ alpha 1
                    , width fill
                    , Styles.transition
                        { property = "all"
                        , duration = duration
                        }
                    ]
                    page
        }

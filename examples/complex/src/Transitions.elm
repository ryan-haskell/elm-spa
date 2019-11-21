module Transitions exposing (transitions)

import Components.Styles as Styles
import Element exposing (..)
import Generated.Docs.Pages
import Layout
import Layouts.Docs
import Layouts.Guide
import Spa.Path exposing (Path)
import Spa.Transition as Transition exposing (Transition)


transitions :
    { layout : Transition (Element msg)
    , page : Transition (Element msg)
    , pages :
        List
            { path : Path
            , transition : Transition (Element msg)
            }
    }
transitions =
    { layout = Transition.fadeUi 300
    , page = Transition.fadeUi 300
    , pages =
        [ { path = Generated.Docs.Pages.path
          , transition = batmanNewspaper 600
          }
        ]
    }



-- MAKE YOUR OWN!


batmanNewspaper : Int -> Transition (Element msg)
batmanNewspaper speed =
    Transition.custom
        { speed = speed
        , invisible =
            \page ->
                el
                    [ alpha 0
                    , width fill
                    , rotate (4 * pi)
                    , scale 0
                    , Styles.transition
                        { property = "all"
                        , speed = speed
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
                        , speed = speed
                        }
                    ]
                    page
        }

module Transitions exposing (transitions)

import Components.Styles as Styles
import Element exposing (..)
import Generated.Docs.Pages
import Generated.Guide.Pages
import Layout
import Layouts.Docs
import Layouts.Guide
import Spa.Pattern exposing (Pattern)
import Spa.Transition as Transition exposing (Transition)


transitions :
    { layout : Transition (Element msg)
    , page : Transition (Element msg)
    , pages :
        List
            { pattern : Pattern
            , transition : Transition (Element msg)
            }
    }
transitions =
    { layout = Transition.fadeUi 300
    , page = Transition.fadeUi 300
    , pages =
        [ { pattern = Generated.Guide.Pages.pattern
          , transition = Transition.none
          }
        , { pattern = Generated.Docs.Pages.pattern
          , transition = batmanNewspaper 500
          }
        ]
    }



-- MAKE YOUR OWN!


batmanNewspaper : Int -> Transition (Element msg)
batmanNewspaper speed =
    Transition.custom
        { speed = speed
        , invisible =
            \{ layout, page } ->
                layout <|
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
            \{ layout, page } ->
                layout <|
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

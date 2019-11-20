module Transitions exposing (transitions)

import Spa.Pattern as Pattern exposing (Pattern, dynamic, static)
import Spa.Transition as Transition exposing (Transition)
import Element exposing (Element)
import Layout
import Layouts.Docs
import Layouts.Guide


transitions :
    { layout : Transition (Element msg)
    , pages : List ( Pattern, Transition (Element msg) )
    }
transitions =
    { layout = Transition.fadeUi 300
    , pages =
        [ ( [], Layout.transition )
        , ( [ Pattern.static "guide" ], Layouts.Guide.transition )
        , ( [ Pattern.static "docs" ], Layouts.Docs.transition )
        ]
    }

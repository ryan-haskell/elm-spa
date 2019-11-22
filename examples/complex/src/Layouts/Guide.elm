module Layouts.Guide exposing (view)

import Utils.Styles as Styles
import Element exposing (..)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page } =
    column
        [ width fill
        , spacing -128
        ]
        [ page
        , row [ centerX, spacing 16 ]
            [ link Styles.link { label = text "programming", url = "/guide/programming" }
            , link Styles.link { label = text "elm", url = "/guide/elm" }
            ]
        ]

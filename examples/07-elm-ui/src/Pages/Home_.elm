module Pages.Home_ exposing (view)

import Element
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , attributes = []
    , element =
        Element.el
            [ Element.centerX
            , Element.centerY
            ]
            (Element.text "Woohoo, it's Elm UI!")
    }

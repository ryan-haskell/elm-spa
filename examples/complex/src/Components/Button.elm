module Components.Button exposing (view)

import Utils.Styles as Styles
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as Attr


view :
    { onPress : Maybe msg
    , label : Element msg
    }
    -> Element msg
view config =
    Input.button
        ((if config.onPress == Nothing then
            alpha 0.6

          else
            alpha 1
         )
            :: Styles.button
        )
        config

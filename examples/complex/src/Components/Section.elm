module Components.Section exposing (view)

import Utils.Styles as Styles
import Element exposing (..)
import Html.Attributes as Attr
import Markdown


view :
    { title : String
    , content : String
    }
    -> Element msg
view config =
    paragraph []
        [ Styles.h3 [] (text config.title)
        , Element.html (Markdown.toHtml [ Attr.class "markdown" ] config.content)
        ]

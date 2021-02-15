module Pages.Home_ exposing (view)

import Html
import View exposing (View)


view : View Never
view =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }

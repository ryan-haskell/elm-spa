module Pages.Home_ exposing (page)

import Html
import View exposing (View)


page : View Never
page =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }

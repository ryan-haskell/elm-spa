module Pages.Static exposing (page)

import Page
import View


page shared req =
    Page.static
        { view = view
        }


view =
    View.placeholder "Static"

module Pages.NotFound exposing (view)

import Components.LinkPage
import Element exposing (..)
import Route


view : Element Never
view =
    Components.LinkPage.view
        { title = "yea, sorry that's it."
        , link =
            { label = "back to homepage"
            , route = Route.Homepage
            }
        }

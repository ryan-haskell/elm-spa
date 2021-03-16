module Pages.Home_ exposing (view)

import Html
import UI
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , body =
        UI.layout
            [ Html.h1 [] [ Html.text "Homepage" ]
            , Html.p [] [ Html.text "This homepage is just a view function, click the links in the navbar to see more pages!" ]
            ]
    }

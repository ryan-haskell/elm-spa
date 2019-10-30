module Pages.Index exposing (Model, Msg, page)

import Application.Page as Page
import Element exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


page =
    Page.static
        { title = "Homepage"
        , view = view
        }


view =
    text "Homepage"

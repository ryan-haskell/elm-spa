module Pages.Top exposing (Flags, Model, Msg, page)

import Browser exposing (Document)
import Global
import Html
import Spa


type alias Flags =
    ()


type alias Model =
    ()


type alias Msg =
    Never


page : Spa.Page Flags Model Msg Global.Model Global.Msg
page =
    Spa.static
        { view = view
        }


view : Document Msg
view =
    { title = "Top"
    , body = [ Html.text "Top" ]
    }

module Pages.Examples exposing (Model, Msg, page)

import Page
import Request
import Shared
import UI.Docs


page : Shared.Model -> Request.With params -> Page.With Model Msg
page =
    UI.Docs.page


type alias Model =
    UI.Docs.Model


type alias Msg =
    UI.Docs.Msg

module Pages.Examples.Section_ exposing (Model, Msg, page)

import Page exposing (Page)
import Request exposing (Request)
import Shared
import UI.Docs


page : Shared.Model -> Request params -> Page Model Msg
page =
        UI.Docs.page


type alias Model =
    UI.Docs.Model


type alias Msg =
    UI.Docs.Msg

module Pages.{{module}} exposing (Model, Msg, page)

import Gen.Params.{{module}} exposing (Params)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


page : Shared.Model -> Request Params -> Page Model Msg
page shared req =
    Page.static
        { view = view
        }


view : View Msg
view =
    View.placeholder "{{module}}"

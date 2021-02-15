module Pages.{{module}} exposing (page)

import Gen.Params.{{module}} exposing (Params)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request Params -> Page () Never
page shared req =
    Page.static
        { view = view
        }


view : View Never
view =
    View.placeholder "{{module}}"

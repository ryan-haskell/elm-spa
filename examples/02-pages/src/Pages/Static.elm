module Pages.Static exposing (page)

import Gen.Params.Static exposing (Params)
import Html
import Page exposing (Page)
import Request
import Shared
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page
page shared req =
    Page.static
        { view = view
        }


view : View msg
view =
    { title = "Static"
    , body =
        UI.layout
            [ UI.h1 "Static"
            , Html.p [] [ Html.text "A static page only renders a view, but has access to shared state and URL information." ]
            ]
    }

module Pages.Dynamic.Name_ exposing (page)

import Gen.Params.Dynamic.Name_ exposing (Params)
import Html exposing (Html)
import Page exposing (Page)
import Request
import Shared
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page
page shared req =
    Page.static
        { view = view req.params
        }


view : Params -> View msg
view params =
    { title = "Dynamic: " ++ params.name
    , body =
        UI.layout
            [ UI.h1 "Dynamic Page"
            , Html.p [] [ Html.text "Dynamic pages with underscores can safely access URL parameters." ]
            , Html.p [] [ Html.text "Because this file is named \"Name_.elm\", it has a \"name\" parameter." ]
            , Html.p [] [ Html.text "Try changing the URL above to something besides \"apple\" or \"banana\"! " ]
            , Html.h2 [] [ Html.text params.name ]
            ]
    }

module Pages.NotFound exposing (Model, Msg, page)

import Gen.Params.NotFound exposing (Params)
import Page
import Request
import Shared
import UI
import UI.Layout
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page =
    UI.Layout.page
        { view = view
        }


type alias Model =
    UI.Layout.Model


type alias Msg =
    UI.Layout.Msg


view : View Msg
view =
    { title = "404 · elm-spa"
    , body =
        [ UI.hero
            { title = "404"
            , description = "that page wasn't found."
            }
        , UI.markdown { withHeaderLinks = False } "## But that's alright.\n\nThere's always [the homepage](/)!"
        ]
    }

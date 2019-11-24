module Pages.Docs exposing (Model, Msg, page)

import Components.Hero as Hero
import Element exposing (..)
import Generated.Params as Params
import Spa.Page
import Ui
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Docs Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "docs | elm-spa"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    Ui.sections
        [ Hero.view
            { title = "docs"
            , subtitle = "\"it's not done until the docs are great!\""
            , links = []
            }
        , Ui.markdown """
### table of contents

1. [installation & setup](#installation)
1. project structure
1. adding pages
1. changing layouts
1. components and reusable ui

"""
        ]

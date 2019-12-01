module Pages.Docs.Top exposing (Model, Msg, page)

import Element exposing (..)
import Generated.Docs.Params as Params
import Spa.Page
import Ui
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Top Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "docs | elm-spa"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    Ui.markdownArticle
        { title = "docs"
        , subtitle = Just "it's not done until the docs are great!"
        , content = """
<iframe></iframe>

### oh hi there!

each section of the docs focus on a single command, concept, or idea in elm-spa.

if you're new to elm-spa, [the guide](/guide) has a complete video tutorial on how to build this site from scratch!
        """
        }

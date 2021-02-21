module Pages.Home_ exposing (Model, Msg, page)

import Gen.Params.Home_ exposing (Params)
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
    { title = "elm-spa"
    , body =
        [ UI.hero
            { title = "elm-spa"
            , description = "single page apps made easy"
            }
        , UI.markdown { withHeaderLinks = False } """
## Build reliable applications.

I need to verify that the line height for paragraphs is reasonable, because if it isn't then I'll need to tweak it a bit until it's actually readable.
Only the most readable lines should be included in the __official__ [guide](/docs), ya dig?

Bippity boppity, my guy.

---
---

## Effortless routing.

Use `elm-spa` to automatically wire up routes and pages.
            """
        ]
    }

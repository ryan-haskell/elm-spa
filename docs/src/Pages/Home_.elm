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
## A work in progress!

This next release of elm-spa isn't _quite_ ready yet. It's currently available in `beta`, and can be installed via __npm__:

```
npm install -g elm-spa@beta
```

For now, feel free to [read the docs](/docs), see the [incomplete guides](/guides), or check the bulleted list of [example projects](/examples)
that aren't available yet.
            """
        ]
    }

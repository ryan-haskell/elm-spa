---
{ "title" : "Page.static"
, "description": "pages without any local state."
}
---

<iframe></iframe>

### pages without state.

Look at this page for example, it's just content. We only care about providing a
`view` function that can't send any messages.

We can use `elm-spa add` to create a page like this:

```bash
npx elm-spa add static Docs.Pages.Static
```

By choosing the `static` keyword in the command above, elm-spa generates this for
us:

```elm
module Pages.Docs.Pages.Static exposing
  ( Model
  , Msg
  , page
  )

import Spa.Page
import Element exposing (..)
import Generated.Docs.Pages.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Static Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "Docs.Pages.Static"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    text "Docs.Pages.Static"
```

From there, we change the `view` function to render whatever we like!

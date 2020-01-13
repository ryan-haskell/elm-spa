---
{ "title" : "Page.sandbox"
, "description": "pages with local state."
}
---

<iframe></iframe>

### pages with local state.

If you want to keep track of something like tabs, an accordion, or something like
Elm's [classic counter example](https://elm-lang.org/examples/buttons), you'll need
to upgrade from [Page.static](./static) to `Page.sandbox`

We can use `elm-spa add` to create a sandbox page like this:

```bash
npx elm-spa add sandbox Counter
```

This will create a file called `src/Pages/Counter.elm` that looks like this:

```elm
module Pages.Example exposing
  ( Model
  , Msg
  , page
  )

import Spa.Page
import Element exposing (..)
import Generated.Params as Params
import Utils.Spa exposing (Page)


page : Page Params.Counter Model Msg model msg appMsg
page =
    Spa.Page.sandbox
        { title = always "Counter"
        , init = always init
        , update = always update
        , view = always view
        }



-- INIT


type alias Model =
    {}


init : Params.Counter -> Model
init _ =
    {}



-- UPDATE


type Msg
    = Msg


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Element Msg
view model =
    text "Counter"
```

### adding in features

From there, we can begin to implement something like a counter by updating the
individual pieces of the page:

```elm
type Model =
  { counter : Int
  }
```

```elm
init : Params.Counter -> Model
init _ =
  { counter = 0
  }
```

```elm
type Msg
  = Increment
  | Decrement
```

```elm
update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      { model | counter = model.counter + 1 }
    Decrement ->
      { model | counter = model.counter - 1 }
```

```elm
view : Model -> Html Msg
view model =
  column []
    [ button []
        { onPress = Just Decrement
        , label = text "-"
        }
    , text (String.fromInt model.counter)
    , button []
        { onPress = Just Increment
        , label = text "+"
        }
    ]
```

Next thing you know, we've got a page at `/counter` with our counter app!
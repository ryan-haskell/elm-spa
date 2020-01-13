---
{ "title": "transitions"
, "description": "unlock client-side superpowers"
}
---

<iframe></iframe>

### client-side rendering with elm

When you click a link on this app, Elm doesn't refetch the entire page back from
the server. Instead, it renders only the components that we want to change, and
updates the URL for you.

This enables us to use __page transitions__ to improve user experience.

### how does it work?

Each elm-spa project looks for a file called `src/Transitions.elm` to describe
two things:

- How the entire app should enter the screen.

- How pages should exit/enter the screen.

Here's the default when you create a project with [elm-spa init](/docs/elm-spa/init):

```elm
module Transitions exposing (transitions)

import Generated.Docs.Pages as Docs
import Spa.Transition as Transition
import Utils.Spa as Spa

transitions : Spa.Transitions msg
transitions =
    { layout = Transition.fadeElmUi 300
    , page = Transition.fadeElmUi 300
    , pages = []
    }
```

When you refresh the page, the whole app will use the `layout` option
and fades it in over 300 milliseconds.

When you click an internal link, pages will fade out and fade in over
300 milliseconds.

### disabling transitions

You can disable transitions with `Transition.none`:

```elm
module Transitions exposing (transitions)

import Generated.Docs.Pages as Docs
import Spa.Transition as Transition
import Utils.Spa as Spa

transitions : Spa.Transitions msg
transitions =
    { layout = Transition.none
    , page = Transition.none
    , pages = []
    }
```

### custom transitions

Fading isn't your thing? Cool! You can use `Transition.custom` to define your own
transitions.

Just provide three properties:

- `duration` - how long the animation lasts

- `invisible` - what the page looks like when invisible

- `visible` - what the page looks like when visible

Here's an example with Elm UI:

```elm
import Element exposing (..)
import Ui
import Spa.Transition as Transition
import Utils.Spa as Spa

scaleTransition :
  Int
  -> Spa.Transition (Element msg)
scaleTransition duration =
  Transition.custom
    { duration = duration 
    , invisible = 
        \page ->
          el
            [ scale 0, Ui.transition duration ]
            page
    , visible = 
        \page ->
          el
            [ scale 1, Ui.transition duration ]
            page
    }
```

And here's an example with HTML and CSS:


```elm
import Html exposing (..)
import Html.Attributes as Attr
import Spa.Transition as Transition
import Utils.Spa as Spa

scaleTransition :
  Int
  -> Spa.Transition (Html msg)
scaleTransition duration =
  Transition.custom
    { duration = duration 
    , invisible = 
        \page ->
          div [ Attr.style "transform" "scale(0)"
              , Attr.style "transition" ("transform " ++ duration ++ "ms")
              ]
              [ page ]
    , visible = 
        \page ->
          div [ Attr.style "transform" "scale(1)"
              , Attr.style "transition" ("transform " ++ duration ++ "ms")
              ]
              [ page ]
    }
```

### only transitioning views that change

You may have noticed a `pages` property from the first example:

```elm
module Transitions exposing (transitions)

import Generated.Docs.Pages as Docs
import Spa.Transition as Transition
import Utils.Spa as Spa

transitions : Spa.Transitions msg
transitions =
    { layout = Transition.fadeElmUi 300
    , page = Transition.fadeElmUi 300
    , pages = []
    }
```

By default, this value is just an empty list. The `pages` property is a way to
prevent things like common sidebars from fading in and out when you click links
in the same view.

Here's how this site uses the `pages` property to prevent the docs sidebar from
fading out when navigating between `/docs/*` routes:

```elm
module Transitions exposing (transitions)

import Generated.Docs.Pages as Docs
import Spa.Transition as Transition
import Utils.Spa as Spa


transitions : Spa.Transitions msg
transitions =
    { layout = Transition.fadeElmUi 500
    , page = Transition.fadeElmUi 300
    , pages =
        [ { path = Docs.path
          , transition = Transition.fadeElmUi 300
          }
        ]
    }
```

Because the sidebar is rendered in `src/Layouts/Docs.elm`, anytime we navigate
within the `Docs.path` (`/docs/*`) routes, it will stay in view.

Here we chose to use the same transition that the other `page` property uses.
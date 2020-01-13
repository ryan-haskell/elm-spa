---
{ "title" : "Page.component"
, "description": "pages that make global updates."
}
---

<iframe></iframe>

### pages that make global updates.

A "component" page is just a [Page.element](./element) that can update the global state
by sending messages!

Both `init` and `update` now return something like this:

```elm
( Model, Cmd Msg, Cmd Global.Msg )
```

We can use `elm-spa add` to create a component page like this:

```bash
npx elm-spa add component SignIn
```

A sign in page is a good example of when we would reach for a component instead
of an element.

We can have the update function send out a `Global` message to update the logged
in user.

It's also very common to omit the `always` to give our functions access
to the `Global.Model` from the page context.

```elm
Page.component
  { title = always title
  , init = init -- *removed always
  , update = update -- *removed always
  , view = view -- *removed always
  , subscriptions = always subscriptions
  }
```

Maybe your `init` does something like this:


```elm
import Global

type alias Model =
  { user : Maybe User
  }

type Msg = NoOp

init :
  PageContext
  -> Params.SignIn
  -> ( Model, Cmd Msg, Cmd Global.Msg )
init context _ =
  ( { user = context.global.user }
  , Cmd.none
  , Global.SignIn "ryan@elm-spa.dev"
  )
```

---
{ "title": "components"
, "description": "reusing ui in your app."
}
---

<iframe></iframe>

### starting simple

Not every component in Elm needs to have it's own `Model`, `Msg`, `init`, 
`update`, `view` defined. In fact, a lot of things can just be a function!

Let's look at an examples of using creating a reusable button in Elm:

```elm
module Pages.Top exposing ( Model, Msg, page )

import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input

type Msg = SignIn | SignOut

view : Element Msg
view =
  Input.button
    [ Font.size 14
    , Font.semiBold
    , Border.solid
    , Border.width 2
    , Border.rounded 4
    , Element.paddingXY 24 8
    , Font.color colors.coral
    , Border.color colors.coral
    , Background.color colors.white
    , Element.pointer
    ]
    { label = Element.text "SignIn"
    , onPress = Just SignIn
    }
```

Here, our homepage (at `src/Pages/Top.elm`) defines a __bunch__ of button styles.
If we wanted to reuse those styles, we can make a function like this:

```elm
module Pages.Top exposing ( Model, Msg, page )

import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input

viewButton : { label : String, onPress : msg } -> Element msg
viewButton options =
  Input.button
    [ Font.size 14
    , Font.semiBold
    , Border.solid
    , Border.width 2
    , Border.rounded 4
    , Element.paddingXY 24 8
    , Font.color colors.coral
    , Border.color colors.coral
    , Background.color colors.white
    , Element.pointer
    ]
    { label = Element.text options.label
    , onPress = Just options.onPress
    }

type Msg = SignIn | SignOut

view : Element Msg
view =
  Element.column []
    [ viewButton
        { label = "Sign in"
        , onPress = SignIn
        }
    , viewButton
        { label = "Sign out"
        , onPress = SignOut
        }
    ]
```

By creating that `viewButton` function, we prevent the need to duplicate our code,
and reuse those styles again for the "Sign out" button!


### sharing between pages

So we love our button so much that we want to reuse it on the "Share" page
(over at `src/Pages/Share.elm`). The only problem is that all the code we wrote
is in the `src/Pages/Top.elm` file.

__So what should we do?__

Let's create a module called `Ui.elm` that has our `viewButton` function in it:

```elm
module Ui exposing ( viewButton )

import Element
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input


viewButton : { label : String, onPress : msg } -> Element msg
viewButton options =
  Input.button
    [ Font.size 14
    , Font.semiBold
    , Border.solid
    , Border.width 2
    , Border.rounded 4
    , Element.paddingXY 24 8
    , Font.color colors.coral
    , Border.color colors.coral
    , Background.color colors.white
    , Element.pointer
    ]
    { label = Element.text options.label
    , onPress = Just options.onPress
    }
```

And update `src/Pages/Top.elm`:

```elm
module Pages.Top exposing ( Model, Msg, page )

import Element
import Ui

type Msg = SignIn | SignOut

view : Element Msg
view =
  Element.column []
    [ Ui.viewButton
        { label = "Sign in"
        , onPress = SignIn
        }
    , Ui.viewButton
        { label = "Sign out"
        , onPress = SignOut
        }
    ]
```

That makes our page a lot shorter, and using `Ui.viewButton` let's readers know 
where that function is coming from!

We can now reuse it on `src/Pages/Share.elm` easily!

```elm
module Pages.Share exposing ( Model, Msg, page )

import Element
import Ui

type Msg = ShareOnTwitter

view : Element Msg
view =
  Ui.viewButton
    { label = "Share"
    , onPress = ShareOnTwitter
    }
```

### when to create a new module

In Elm, we _usually_ make a module around data structures. The creator of the language,
Evan Czaplicki, has a [really great talk](https://www.youtube.com/watch?v=XpDsk374LDE)
about that idea here.

For this site, I made the navbar into it's own file (at `src/Components/Navbar.elm`),
but I could have just as easily made a function in `src/Ui.elm` that exposed `viewNavbar`.

Directly mapping ideas from JS frameworks like React may lead you down a frustrating path.
What makes sense for scaling a JavaScript app might not translate in Elm!

If you find yourself creating components like this:

```elm
module Components.Example exposing
  ( Model
  , Msg
  , init
  , update
  , view
  )

-- code
```

You'll end up creating a verbosity problem for components (the same one 
that __elm-spa__ was designed to fix for pages!)

```elm
module Pages.Example exposing (Model, Msg, page)

import Components.Foo as Foo
import Components.Bar as Bar
import Components.Baz as Baz

type alias Model =
  { foo : Foo.Model
  , bar : Bar.Model
  , baz : Baz.Model
  }

type Msg
  = FromFoo Foo.Msg
  | FromBar Bar.Msg
  | FromBaz Baz.Msg

view : Model -> Element Msg
view model =
  Element.column []
    [ Element.map FromFoo (Foo.view model.foo)
    , Element.map FromBar (Bar.view model.bar)
    , Element.map FromBaz (Baz.view model.baz)
    ]

update : Msg -> Model -> Model
update msg model =
  case msg of
    FromFoo msg_ ->
      { model | foo = Foo.update msg_ model.foo }
    FromBar msg_ ->
      { model | bar = Bar.update msg_ model.bar }
    FromBaz msg_ ->
      { model | baz = Baz.update msg_ model.baz }
```

There's nothing _wrong_ with the code in the example above! Maybe `Foo` needs to
be complex!

But start with the simplest strategy first. Maybe `Bar` and `Baz` don't need to
follow that pattern:

```elm
module Pages.Example exposing (Model, Msg, page)

import Components.Foo as Foo
import Ui

type alias Model =
  { user : Maybe String
  , foo : Foo.Model
  }

type Msg
  = FromFoo Foo.Msg
  | SignOut

view : Model -> Element Msg
view model =
  Element.column []
    [ Element.map FromFoo (Foo.view model.foo)
    , Ui.viewBar model.username
    , Ui.viewBaz { onClick = SignOut }
    ]

update : Msg -> Model -> Model
update msg model =
  case msg of
    FromFoo msg_ ->
      { model | foo = Foo.update msg_ model.foo }
    SignOut ->
      { model | user = Nothing }
```

# ryannhg/elm-app
> a way to build single page apps with Elm.

## installing

```
elm install ryannhg/elm-app
```

## motivation

Every time I try and create a single page application from scratch in Elm, I end up repeating a few first steps from scratch:

- __Routing__ - Implementing `onUrlChange` and `onUrlRequest` for my `update` function.

- __Page Transitions__ - Fading in the whole app on load and fading in/out the pages (not the persistent stuff) on route change.

- __Wiring up pages__ - Every page has it's own `Model`, `Msg`, `init`, `update`, `view`, and `subscriptions`. I need to bring those together at the top level.

- __Sharing app model__ - In addition to updating the _page model_, I need a way for pages to update the _shared app model_ used across pages (signed in users).

This package is an attempt to create a few abstractions on top of `Browser.application` to make creating single page applications focus on what makes __your app unique__.


## is it real?

- A working demo is available online here: [https://elm-app-demo.netlify.com/](https://elm-app-demo.netlify.com/)

- And you can play around with an example yourself in the repo: [https://github.com/ryannhg/elm-app/tree/master/examples/basic](https://github.com/ryannhg/elm-app/tree/master/examples/basic) around with the files in `examples/basic/src` and change things!

---

## examples are helpful!

Let's walk through the package together, at a high-level, with some code!


### src/Main.elm

```
our-project/
  elm.json
  src/
    Main.elm ✨
```

This is the __entrypoint__ to the application, and connects all the parts of our `Application` together:

```elm
module Main exposing (main)

import Application

main =
  Application.create
    { routing = -- TODO
    , layout = -- TODO
    , pages = -- TODO
    }
```

As you can see, `Application.create` is a function that takes in a `record` with three properties:

1. __routing__ - handles URLs and page transitions

2. __layout__ - the app-level `init`, `update`, `view`, etc.

3. __pages__ - the page-level `init`, `update`, `view`, etc.


#### routing

```elm
module Main exposing (main)

import Application
import Route ✨

main =
  Application.create
    { routing =
        { fromUrl = Route.fromUrl ✨
        , toPath = Route.toPath ✨
        , transitionSpeed = 200  ✨
        }
    , layout = -- TODO
    , pages = -- TODO
    }
```

The record for `routing` only has three properties:

1. __fromUrl__ - a function that turns a `Url` into a `Route`

2. __toPath__ - a function that turns a `Route` into a `String` used for links.

3. __transitionSpeed__ - number of __milliseconds__ it takes to fade in/out pages.

The implementation for `fromUrl` and `toPath` don't come from the `src/Main.elm`. Instead we create a new file called `src/Route.elm`, which handles all this for us in one place!

We'll link to that in a bit!

#### layout

```elm
module Main exposing (main)

import Application
import Route
import Components.Layout as Layout ✨

main =
  Application.create
    { routing =
        { fromUrl = Route.fromUrl
        , toPath = Route.toPath
        , transitionSpeed = 200 
        }
    , layout =
        { init = Layout.init ✨
        , update = Layout.update ✨
        , view = Layout.view ✨
        , subscriptions = Layout.subscriptions ✨
        }
    , pages = -- TODO
    }
```

The `layout` property introduces four new pieces:

1. __init__ - how to initialize the shared state.

2. __update__ - how to update the app-level state (and routing commands).

3. __view__ - the app-level view (and where to render our page view)

4. __subscriptions__ - app-level subscriptions (regardless of which page we're on)

Just like before, a new file `src/Components/Layout.elm` will contain all the functions we'll need for the layout, so that `Main.elm` is relatively focused.

#### pages


```elm
module Main exposing (main)

import Application
import Route
import Components.Layout as Layout
import Pages ✨

main =
  Application.create
    { routing =
        { fromUrl = Route.fromUrl
        , toPath = Route.toPath
        , transitionSpeed = 200 
        }
    , layout =
        { init = Layout.init
        , update = Layout.update
        , view = Layout.view
        , subscriptions = Layout.subscriptions
        }
    , pages =
        { init = Pages.init ✨
        , update = Pages.update ✨
        , bundle = Pages.bundle ✨
        }
    }
```

Much like the last property, `pages` is just a few functions.

The `init` and `update` parts are fairly the same, but there's a new property that might look strange: `bundle`.

The "bundle" is a combination of `view`, `title`, `subscriptions` that allows our new `src/Pages.elm` file to reduce a bit of boilerplate! (There's a better explanation in the `src/Pages.elm` section of the guide.)

#### that's it for Main.elm!

As the final touch, we can update our import statements to add in a type annotation for the `main` function:

```elm
module Main exposing (main)

import Application exposing (Application) ✨
import Flags exposing (Flags) ✨
import Global ✨
import Route exposing (Route) ✨
import Components.Layout as Layout
import Pages

main : Application Flags Route Global.Model Global.Msg Pages.Model Pages.Msg ✨
main =
  Application.create
    { routing =
        { fromUrl = Route.fromUrl
        , toPath = Route.toPath
        , transitionSpeed = 200 
        }
    , layout =
        { init = Layout.init
        , update = Layout.update
        , view = Layout.view
        , subscriptions = Layout.subscriptions
        }
    , pages =
        { init = Pages.init
        , update = Pages.update
        , bundle = Pages.bundle
        }
    }
```

Instead of main being the traditional `Program Flags Model Msg` type, here we use `Application Flags Route Global.Model Global.Msg Pages.Model Pages.Msg`, which is very long and spooky!

This is caused by the fact that our `Application.create` needs to know more about the `Flags`, `Route`, `Global`, and `Pages` types so it can do work for us.

But enough of that– let's move on to routing next!

---

### src/Route.elm

```
our-project/
  elm.json
  src/
    Main.elm
    Route.elm ✨
```

in our new file, we need to create a [custom type](#custom-type) to handle all the possible routes.

```elm
module Route exposing (Route(..))

type Route
  = Homepage
```

For now, there is only one route called `Homepage`.

__Note:__ Our `exposing` statement has `Route(..)` instead of `Route`. so we can access `Route.Homepage` outside of this module (We'll come back to that later)

For `src/Main.elm` to work, we also need to create and expose `fromUrl` and `toPath` so our application handles routing and page navigation correctly!

For that, we need to install the official `elm/url` package:

```
elm install elm/url
```

And use the newly installed `Url` and `Url.Parser` modules like this:

```elm
module Route exposing
  ( Route(..)
  , fromUrl ✨
  , toPath ✨
  )

import Url exposing (Url) ✨
import Url.Parser as Parser exposing (Parser) ✨

type Route
  = Homepage

fromUrl : Url -> Route ✨
-- TODO

toPath : Route -> String ✨
-- TODO
```

#### fromUrl

Let's get started on implementing `fromUrl` by using the `Parser` module:

```elm
type Route
  = Homepage
  | NotFound ✨ -- see note #2

fromUrl : Url -> Route
fromUrl url =
  let
    router =
      Parser.oneOf
        [ Parser.map Homepage Parser.top ✨ -- see note #1
        ]
  in
    Parser.parse router url
    |> Maybe.withDefault NotFound ✨ -- see note #2
```

__Notes__

1. Here we're matching the top url `/` with our `Homepage`

2. `Parser.parse` returns a `Maybe Route` because it not find a match in our `router`. That means we need to add a `NotFound` case (good catch, Elm!)

#### toPath

It turns out `toPath` is really easy, its just a case expression:

```elm
toPath : Route -> String ✨
toPath route =
  case route of
    Homepage -> "/"
    NotFound -> "/not-found"
```

#### that's it for Route.elm!

here's the complete file we made.

```elm
module Route exposing
  ( Route(..)
  , fromUrl
  , toPath
  )

import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)

type Route
  = Homepage
  | NotFound

fromUrl : Url -> Route
fromUrl url =
  let
    router =
      Parser.oneOf
        [ Parser.map Homepage Parser.top
        ]
  in
    Parser.parse router url
    |> Maybe.withDefault NotFound

toPath : Route -> String
toPath route =
  case route of
    Homepage -> "/"
    NotFound -> "/not-found"
```

You can learn how to add more routes by looking at: 

1. __the `elm/url` docs__ - https://package.elm-lang.org/packages/elm/url/latest

2. __the example in this repo__ -https://github.com/ryannhg/elm-app/blob/master/examples/basic/src/Route.elm

---

### src/Flags.elm

```
our-project/
  elm.json
  src/
    Main.elm
    Route.elm
    Flags.elm ✨
```

For this app, we don't actually have flags, so we return an empty tuple!

```elm
module Flags exposing (Flags)

type alias Flags = ()
```

Let's move onto something more interesting!

---

### src/Global.elm

```
our-project/
  elm.json
  src/
    Main.elm
    Route.elm
    Flags.elm
    Global.elm ✨
```

Let's create `src/Global.elm` to define the `Model` and `Msg` types we'll share across pages and use in our layout functions:

```elm
module Global exposing ( Model, Msg(..) )

type alias Model =
    { isSignedIn : Bool
    }

type Msg
    = SignIn
    | SignOut
```

Here we create a simple record to keep track of the user's sign in status.

Let's use `Global.Model` and `Global.Msg` in our layout:


### src/Components/Layout.elm

```
our-project/
  elm.json
  src/
    Main.elm
    Route.elm
    Flags.elm
    Global.elm
    Components/
      Layout.elm ✨
```

To implement an app-level layout, we'll need a new file:

```elm
module Components.Layout exposing (init, update, view, subscriptions)

import Global
import Route exposing (Route)

-- ...
```

This file needs to export the following four functions:

#### init

```elm
init :
    { navigateTo : Route -> Cmd msg
    , route : Route
    , flags : Flags
    }
    -> ( Global.Model, Cmd Global.Msg, Cmd msg )
init _ =
  ( { isSignedIn = False }
  , Cmd.none
  , Cmd.none
  )
```

Initially, our layout takes in three inputs:

- __messages__ - not used here, but allows programmatic navigation to other pages.

- __route__ - the current route

- __flags__ - the initial JSON passed in with the app.

For our example, we set `isSignedIn` to `False`, don't perform any `Global.Msg` side effects, nor use `messages.navigateTo` to change to another page.

#### update

```elm
update :
    { navigateTo : Route -> Cmd msg
    , route : Route
    , flags : Flags
    }
    -> Global.Msg
    -> Global.Model
    -> ( Global.Model, Cmd Global.Msg, Cmd msg )
update { navigateTo } msg model =
  case msg of
    Global.SignIn ->
      ( { model | isSignedIn = True }
      , Cmd.none
      , navigateTo Route.Homepage
      )

    Global.SignOut ->
      ( { model | isSignedIn = False }
      , Cmd.none
      , navigateTo Route.SignIn
      )
```

Here, our layout's update takes four inputs:

- __messages__ - allows programmatic navigation to other pages.

- __route__ - the current route

- __flags__ - the initial JSON passed in with the app.


---

## uh... still writing the docs 😬

dont look at me... dont look at me!!!

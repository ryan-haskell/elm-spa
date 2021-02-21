# Pages

In __elm-spa__, every URL connects to a single page. Let's take a closer look at the homepage we created earlier with the `elm-spa new` command:

```elm
module Pages.Home_ exposing (view)

import Html

view =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }
```

This homepage renders the tab `title`, and a HTML `body` onto the page. This is great when you have a static page that just needs to render some HTML.

Because the file is named `Home_.elm`, we know it's the homepage. These 8 lines of code are all we need to tell __elm-spa__ we'd like to render this when users visit the homepage.

For real world applications, our pages will need to do more than print "Hello, world!". Let's upgrade!

### Upgrading "Hello World!"

Let's start by introducing the `page` function, marking the start of our journey from "Hello world!" to the real world:

```elm
module Pages.Home_ exposing (page)

import Html
import Page exposing (Page)
import Request exposing (Request)
import Shared

page : Shared.Model -> Request -> Page
page shared req =
    Page.static
        { view = view
        }

view =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }
```

Here, our code hasn't changed very much- except now we have this new `page` function that:

1. Accepts two inputs: `Shared.Model` and `Request`
2. Returns a `Page` value
3. Has been __exposed__ at the top of the file

> Exposing `page` from this module lets __elm-spa__ know to use it instead of the plain `view` function from before.

This new `page` will always get the latest `Shared.Model` and a `Request` value (that contains URL information).

This is great, but there is still more that our `page` function can do other than render a view!

### Beyond static pages 

The right page to use is the __simplest page__ that can support what you need! As we move from `Page.static` to `Page.advanced`, we'll have more capabilities, but at the cost of more code.

This section of the guide will introduce you to the functions exposed by the `Page` module, so you have all the information you need.

__[Page.static](#pagestatic)__ - for pages that only render a view.

```elm
Page.static
    { view : View Never
    }
```

__[Page.sandbox](#pagesandbox)__ - for pages that need to keep track of state.

```elm
Page.sandbox
    { init : Model
    , update : Msg -> Model -> Model
    , view : Model -> View Msg
    }
```

__[Page.element](#pageelement)__ - for pages that send HTTP requests or continually listen for events from the browser or user.

```elm
Page.element
    { init : ( Model, Cmd Msg )
    , update : Msg -> Model -> ( Model, Cmd Msg )
    , view : Model -> View Msg
    , subscriptions : Model -> Sub Msg
    }
```

__[Page.advanced](#pageadvanced)__ - For pages that need to sign in a user or work with other details that should persist between page navigation.

```elm
Page.advanced
    { init : ( Model, Effect Msg )
    , update : Msg -> Model -> ( Model, Effect Msg )
    , view : Model -> View Msg
    , subscriptions : Model -> Sub Msg
    }
```

### Working with pages

The `page` function allows us to pass `Shared.Model` and `Request` information to any inner function that needs it.

```elm
page shared req =
  Page.sandbox
    { init = init shared     -- pass init "shared"
    , update = update req    -- pass update "req"
    , view = view
    }
```

Imagine your `init` function needs access to `shared` data, and your `update` function needs URL information from the current `req`.

Because `page` is a function, you can pass those values in where you see fit. This means the type annotations of those inner functions should also update:

__Before__
```elm
page shared req =
  Page.sandbox
    { init = init
    , update = update
    , view = view
    }

init : Model
update : Msg -> Model -> Model
view : Model -> View Msg
```

__After__

```elm
page shared req =
  Page.sandbox
    { init = init shared    
    , update = update req
    , view = view
    }

init : Shared.Model -> Model
update : Request Params -> Msg -> Model -> Model
view : Model -> View Msg
```

Notice how the type annotations of `init` and `update` changed to accept their input? (The `view` function didn't change because it didn't get any new values)

## Page.static

```elm
module Pages.Example exposing (page)
```

```elm
Page.static
    { view = view
    }
```

```elm
view : View Never
```

( video introducing concept )

## Page.sandbox

```elm
module Pages.Example exposing (Model, Msg, page)
```

```elm
Page.sandbox
    { init = init
    , update = update
    , view = view
    }
```

```elm
init : Model
update : Msg -> Model -> Model
view : Model -> View Msg
```

( video introducing concept )

## Page.element

```elm
module Pages.Example exposing (Model, Msg, page)
```

```elm
Page.element
    { init : ( Model, Cmd Msg )
    , update : Msg -> Model -> ( Model, Cmd Msg )
    , view : Model -> View Msg
    , subscriptions : Model -> Sub Msg
    }
```

( video introducing concept )

## Page.advanced

```elm
module Pages.Example exposing (Model, Msg, page)
```

```elm
Page.advanced
    { init : ( Model, Effect Msg )
    , update : Msg -> Model -> ( Model, Effect Msg )
    , view : Model -> View Msg
    , subscriptions : Model -> Sub Msg
    }
```

( video introducing concept )


## Page.protected

Each of the four page types also have a "protected" version, that is guaranteed to receive a `User` or redirect if no user is signed in.

```elm
Page.protected.static
    { view : User -> View Never
    }

Page.protected.sandbox
    { init : User -> Model
    , update : User -> Msg -> Model -> Model
    , view : User -> Model -> View Msg
    }

-- Page.protected.element

-- Page.protected.advanced
```

When you are ready, you can learn more about this in the [user authentication example](/examples/authentication).

---

__What's next?__

Let me introduce you to the `Request Params` type we pass into our pages in the [next section on requests](./requests)
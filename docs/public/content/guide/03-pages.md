# Pages

In __elm-spa__, every URL connects to a single page. Let's take a closer look at the homepage created with the `elm-spa new` command:

```elm
module Pages.Home_ exposing (view)

import Html
import View exposing (View)

view : View msg
view =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }
```

This homepage renders __"Homepage"__ in the browser tab, and __"Hello, world!"__ onto the page.

Because the file is named `Home_.elm`, elm-spa knows this is the homepage. Visiting `http://localhost:1234` in a web browser will render this view.

A `view` function is perfect when all you need is to render some HTML on the screen. But many web pages in the real world do more interesting things!

### Upgrading "Hello, world!"

Let's start by adding a new `page` function:

```elm
module Pages.Home_ exposing (page)

import Html
import Page exposing (Page)
import Request exposing (Request)
import Shared
import View exposing (View)

page : Shared.Model -> Request -> Page
page shared req =
    Page.static
        { view = view
        }

view : View msg
view =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }
```

We haven't changed the original code much- except we've added a new `page` function that:

1. Accepts 2 inputs: `Shared.Model` and `Request`
2. Returns a `Page` value
3. Has been __exposed__ at the top of the file.

> Exposing `page` from this module lets __elm-spa__ know we want to use `page` instead of the plain `view` function from before.

The `view` function from before is now passed into `page`. In the web browser, we still see __"Hello, world!"__. However, this page now has access to two new bits of information!

1. `Shared.Model` is our global application state, which might contain the signed-in user, settings, or other things that should persist as we move from one page to another.
2. `Request` is a record with access to the current route, query parameters, and any other information about the current URL.

You can rely on the fact that the `page` will always be passed the latest `Shared.Model` and `Request` value. If we want either of these values to be available in our `view` function, we pass them in like so:

```elm
page : Shared.Model -> Request -> Page
page shared req =
    Page.static
        { view = view req  -- passing in req here!
        }
```

Now our `view` function can read the current `URL` value:

```elm
view : Request -> View msg
view req =
    { title = "Homepage"
    , body =
        [ Html.text ("Hello, " ++ req.url.host ++ "!")
        ]
    }
```

Now the browser should display __"Hello, localhost!"__

### Beyond static pages

You might have noticed `Page.static` earlier in our page function. This is one of the built in __page types__ that is built-in to __elm-spa__.

The rest of this section will introduce you to the other __page types__ exposed by the `Page` module, so you know which one to reach for.

Don't forget to run the command
```terminal
elm-spa gen
```
to generate the modules needed for the existing code.
Use
```terminal
elm-spa watch
```
or
```terminal
elm-spa server
```
to generate the modules while you are editing the files.

> Always choose the __simplest__ page type for the job– and reach for the more advanced ones when your page _really_ needs the extra features!

- __[Page.static](#pagestatic)__ - for pages that only render a view.
- __[Page.sandbox](#pagesandbox)__ - for pages that need to keep track of state.
- __[Page.element](#pageelement)__ - for pages that send HTTP requests or continually listen for events from the browser or user.
- __[Page.advanced](#pageadvanced)__ - for pages that need to sign in a user or work with other details that should persist between page navigation.


## Page.static

```terminal
elm-spa add /example static
```

This was the page type we looked at above. It is perfect for pages that render static HTML, but might need access to the `Shared.Model` or `Request` values.

```elm
module Pages.Example exposing (page)


page : Shared.Model -> Request -> Page
page shared req =
    Page.static
        { view = view
        }


view : View msg
```


## Page.sandbox

```terminal
elm-spa add /example sandbox
```

This is the first __page type__ that introduces [the Elm architecture](https://guide.elm-lang.org/architecture/), which uses `Model` to store the current page state and `Msg` to define what actions users can take on this page.

It's time to upgrade to `Page.sandbox` when you __need to track state__ on the page. Here are a few examples of things you'd store in page state:

- The current slide of a carousel
- The selected tab section to view
- The open / close state of a modal

All these examples require us to be able to __initialize__ a `Model`, __update__ it based on `Msg` values sent from the __view__.

If you are new to the Elm architecture, be sure to visit [guide.elm-lang.org](https://guide.elm-lang.org/architecture/). We'll be using it for all the upcoming page types!


```elm
module Pages.Example exposing (Model, Msg, page)


page : Shared.Model -> Request -> Page.With Model Msg
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

> Our `page` function now returns `Page.With Model Msg` instead of `Page`. This is because our page is now stateful.

_( Inspired by [__Browser.sandbox__](https://package.elm-lang.org/packages/elm/browser/latest/Browser#sandbox) )_

## Page.element

```terminal
elm-spa add /example element
```

When you are ready to send __HTTP requests__ or __subscribe to events__ like keyboard presses, mouse move, or incoming data from JS– upgrade to `Page.element`.

This is the same as `Page.sandbox`, but introduces `Cmd Msg` and `Sub Msg` to handle side effects.

```elm
module Pages.Example exposing (Model, Msg, page)


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
update : Msg -> Model -> ( Model, Cmd Msg )
view : Model -> View Msg
subscriptions : Model -> Sub Msg
```

_( Inspired by [__Browser.element__](https://package.elm-lang.org/packages/elm/browser/latest/Browser#element) )_

## Page.advanced

```terminal
elm-spa add /example advanced
```

For many applications, `Page.element` is all you need to store a `Model`, handle `Msg` values, and work with side-effects.

Some Elm users prefer sending global updates directly from their pages, so we've included this `Page.advanced` page type.

Using a custom `Effect` module, users are able to send `Cmd Msg` value via `Effect.fromCmd` or `Shared.Msg` values with `Effect.fromSharedMsg`.


```elm
module Pages.Example exposing (Model, Msg, page)


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Effect Msg )
update : Msg -> Model -> ( Model, Effect Msg )
view : Model -> View Msg
subscriptions : Model -> Sub Msg
```

This `Effect Msg` value also allows support for folks using [elm-program-test](https://package.elm-lang.org/packages/avh4/elm-program-test/latest/), which requires users to define their own custom type on top of `Cmd Msg`. More about that in the [testing guide](/examples/06-testing)


## Page.protected

Each of those four __page types__ also have a __protected__ version. This means pages are guaranteed to receive a `User` or redirect if no user is signed in.

```elm
-- not protected
Page.sandbox                  
    { init : Model
    , update : Msg -> Model -> Model
    , view : Model -> View Msg
    }

-- protected
Page.protected.sandbox :
     User ->
          { init : Model
          , update : Msg -> Model -> Model
          , view : Model -> View Msg
          }
```

When you are ready for user authentication, you can learn more about using `Page.protected` in the [authentication guide](/examples/04-authentication).

---

__Next up:__ [Requests](./04-requests)

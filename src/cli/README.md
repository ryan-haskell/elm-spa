# elm-spa cli
> the command-line interface for __elm-spa__

## installation

```bash
npm install -g elm-spa
```

## usage

```
$ elm-spa help
```
```
elm-spa – version 6.0.0

Commands:
elm-spa new . . . . . . . . .  create a new project
elm-spa add <url> . . . . . . . . create a new page
elm-spa build . . . . . . one-time production build
elm-spa watch . . . . . . .  runs build as you code
elm-spa server  . . . . . . start a live dev server

Visit https://elm-spa.dev for more!
```


# Docs

Here are a few reasons to use __elm-spa__:

1. __Automatic routing__ - automatically generates URL routing and connects your pages together, based on an easy-to-remember naming convention.
1. __Keep pages simple__ - comes with a friendly API for making pages as lightweight or advanced as you need.
1. __Storage, authentication, & more__ - the official website has guides for building common SPA features for real world applications.

## Routing

URL routing is __automatically__ generated from the file names in `src/Pages`:

URL | Filepath
--- | ---
`/` | `Home_.elm`
`/about-us` | `AboutUs.elm`
`/about-us/offices` | `AboutUs/Offices.elm`
`/posts` | `Posts.elm`
`/posts/:id` | `Posts/Id_.elm`
`/users/:name/settings` | `Users/Name_/Settings.elm`
`/users/:name/posts/:id` | `Users/Name_/Posts/Id_.elm`

### Top-level Route

The reserved filename `Home_.elm` is used to indicate the homepage at `/`.

This is different than `Home.elm` (without the underscore) would handle requests to `/home`.

### Static Routes

You can make a page at `/hello/world` by creating a new file at `src/Pages/Hello/World.elm`.

All module names are converted into lowercase, dash-separated lists (kebab-case) automatically:

Filepath | URL
--- | ---
`AboutUs.elm` | `/about-us`
`AboutUs/Offices.elm` | `/about-us/offices`
`SomethingWithCapitalLetters.elm` | `/something-with-capital-letters`

### Dynamic Routes

You can suffix any file with `_` to indicate a __dynamic route__. A dynamic route passes it's URL parameters within the `Request params` value passed into each `page`.

Here's an example:

`src/Pages/Users/Name_.elm`

URL | `req.params`
--- | ---
`/users/`_`ryan`_ | `{ name = "ryan" }`
`/users/`_`erik`_ | `{ name = "erik" }`
`/users/`_`alexa`_ | `{ name = "alexa" }`


### Nested Dynamic Routes

You can also suffix _folders_ with `_` to support __nested dynamic routes__.

Here's an example:

`src/Pages/Users/Name_/Posts/Id_.elm`

URL | `req.params`
--- | ---
`/users/`_`ryan`_`/posts/`_`123`_ | `{ name = "ryan", id = "123" }`
`/users/`_`ryan`_`/posts/`_`456`_ | `{ name = "ryan", id = "456" }`
`/users/`_`erik`_`/posts/`_`789`_ | `{ name = "erik", id = "789" }`
`/users/`_`abc`_`/posts/`_`xyz`_  | `{ name = "abc", id = "xyz" }`

## Pages

Every module in `src/Pages` __must__ expose three things for elm-spa to work as expected:

1. `Model` - the model of the page.
2. `Msg` - the messages that page sends.
3. `page` - a function returning a `Page Model Msg`

Every `page` should have this signature:

```elm
page : Shared.Model -> Request Params -> Page Model Msg
```

Here's how you can create pages:

### `Page.static`

The simplest page only needs a `view` function:

```elm
Page.static
    { view = view
    }
```

```elm
view : View msg
```

__Note:__ Instead of returning `Html msg`, all views return an application-defined `View msg`– this allows us to use [elm-ui](#todo), [elm-css](#todo), [elm/html](#todo), or your own custom view library! 

(We'll learn more about that later)

### `Page.sandbox`

If you need to track state, you can upgrade to a `sandbox` page:

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

This is based on the [Browser.sandbox](#todo) API in `elm/browser`, which introduces the Elm architecture.

### `Page.element`

To send `Cmd msg` or listen for `Sub msg` events, you'll need a more complex API:

```elm
Page.element
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }
```

```elm
init : ( Model, Cmd Msg )
update : Msg -> Model -> ( Model, Cmd Msg )
view : Model -> View Msg
subscriptions : Model -> Sub Msg
```

`Cmd` let you send things like HTTP requests, while `Sub` let your application listen for DOM events and other external changes. 

## `Request params`

Each page has access to a `Request params` value, which contains information about the current URL request:

```elm
request.params    -- parameters for dynamic routes
request.query     -- a dictionary of query parameters
request.key       -- used for programmatic navigation
request.url       -- the original raw URL value
```

__Note:__ For static routes like `/about-us`, the `request.params` value will be `()`.

However, for routes like `/users/:id`, `request.params.id` will contain the `String` value for the dynamic `id` parameter.

## `Shared.Model`

Sometimes you want to persist information between pages, like a signed-in user. __elm-spa__ provides all pages with a `Shared.Model` value, so you can easily verify that a user is signed in!

Updates to that `Shared.Model` are possible via `Cmd msg` sent by `Page.element` pages. The official guide will walk through that process in more depth, if you're interested in learning more.



# contributing

The CLI is written with TypeScript + NodeJS. Here's how you can get started contributing:

```bash
npm start       # first time dev setup
```

```bash
npm run dev     # compiles as you code
npm run build   # one-time production build
npm run test    # run test suite
```

## playing with the CLI locally

Here's how you can make the `elm-spa` command work with your local build of this
repo.

```bash
npm remove -g elm-spa   # remove any existing `elm-spa` installs
npm link                # make `elm-spa` refer to our local code
```
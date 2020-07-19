# Routing

With __elm-spa__, the names of pages in the `src/Pages` folder automatically generate your routes! Check out the following examples to learn more.

## Static Routes

You can create a static route like `/contact` or `/not-found` by creating an elm file in `src/Pages`:

File | URL
:-- | :--
`People.elm` | `/people`
`About/Careers.elm` | `/about/careers`
`OurTeam.elm` | `/our-team`

__Capitalization matters!__ Notice how `OurTeam` became `our-team`? Capital letters within file names are translated to dashes in URLs.

## Top Level Routes

Routes like the homepage use the reserved `Top` keyword to indicate that a page should not be a static route.

File | URL
:-- | :--
`Top.elm` | `/`
`Example/Top.elm` | `/example`
`Top/Top.elm` | `/top`

__Reserved, but possible!__ If you actually need a `/top` route, you can still make one by using `Top.elm` within a `Top` folder. (As shown above!)

## Dynamic Routes

Sometimes it's nice to have one page that works for slightly different URLs. __elm-spa__ uses this convention in file names to indicate a dynamic route:

__`Authors/Name_String.elm`__

URL | Params
:-- | :--
`/authors/ryan` | `{ name = "ryan" }`
`/authors/alexa` | `{ name = "alexa" }`

__`Posts/Id_Int.elm`__

URL | Params
:-- | :--
`/posts/123` | `{ id = 123 }`
`/posts/456` | `{ id = 456 }`

You can access these dynamic parameters from the `Url Params` value passed into each page type!

__Supported Parameters__: Only `String` and `Int` dynamic parameters are supported.

### Nested Dynamic Routes

You can also nest your dynamic routes. Here's an example:


__`Users/User_String/Posts/Id_Int.elm`__

URL | Params
:-- | :--
`/users/ryan/posts/123` | `{ user = "ryan"`<br/>`, id = 123`<br/>`}`
`/users/alexa/posts/456` | `{ user = "alexa"`<br/>`, id = 456`<br/>`}`

## URL Params

As we'll see in the next section, every page will get access to `Url Params`– these allow you access a few things:

```elm
type alias Url params =
  { params : params
  , query : Dict String String
  , key : Browser.Navigation.Key
  , rawUrl : Url.Url
  }
```

#### params

Each dynamic page has its own params, pulled from the URL. There are examples in the "Params" column above.

```elm
type alias Params =
  { name : String
  }

view : Url Params -> Document Msg
view url =
  { title = "Author: " ++ url.params.name
  , body = -- ...
  }
```

#### query

A dictionary of query parameters. Here are some examples:

```elm
-- https://elm-spa.dev
Dict.get "name" url.query == Nothing

-- https://elm-spa.dev?name=ryan
Dict.get "name" url.query == Just "ryan"

-- https://elm-spa.dev?name
Dict.get "name" url.query == Just ""
```

#### key

Required for programmatic navigation with `Nav.pushUrl` and other functions from [elm/browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#pushUrl)

#### rawUrl

The original URL in case you need any other information like the protocol, port, etc.

## Programmatic Navigation

The [elm/browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation#pushUrl) package allows us to programmatically navigate to another page, if we provide a `Browser.Navigation.Key`. Fortunately, the `Url params` record above contains that `key`, and is available on all pages (and the `Shared` module)!

I recommend creating a common module, like `Utils.Route` that you can use in your application:

```elm
module Utils.Route exposing (navigate)

import Browser.Navigation as Nav
import Spa.Generated.Route as Route exposing (Route)


navigate : Nav.Key -> Route -> Cmd msg
navigate key route =
  Nav.pushUrl key (Route.toString route)
```

From there, you can call `Utils.Route.navigate` from any `init` or `update` function with your desired route.

```elm
module Pages.Dashboard exposing (..)

import Utils.Route

-- ...

init : Url Params -> ( Model, Cmd Msg )
init url =
  ( Model { ... }
  , Utils.Route.navigate url.key Route.SignIn
  )
```

---

Let's take a closer look at [Pages](/guide/pages)!

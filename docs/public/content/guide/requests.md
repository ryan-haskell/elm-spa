# Requests

Every URL that a user visits in your application contains useful information. When __elm-spa__ gets an updated URL, it passes that information to every [Page](/guide/pages) as a `Request` value.


This section of the guide breaks down the [Request](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/ElmSpa-Request) type exposed by the official Elm package:

```elm
type alias Request params =
  { params : params
  , query : Dict String String
  , url : Url
  , route : Route
  , key : Nav.Key
  }
```

## URL Parameters

Every request has parameters that you can rely on. If you are on a [dynamic route](/guide/routing#dynamic-routes), you have access to that route's URL parameters:

URL | Params
 --- | ---
`/` | `()`
`/about-us` | `()`
`/people/:name` | `{ name : String }`
`/posts/:post/comments/:comment` | `{ post : String, comment : String }`

The first two examples from that table are __static routes__, so there are no dynamic parameters available. The last two examples are guaranteed to have values at `req.params`.

All dynamic parameters are `String` types, so feel free to validate them at the page level.

```elm
greet : Request { name : String } -> String
greet req =
  "Hello, " ++ req.params.name ++ "!"
```

__Note:__ When working with [shared state](/guide/shared-state), all requests are `Request ()`.

## Query Parameters

For convenience, query parameters are automatically turned into a `Dict String String`, making it easy to handle common query URL parameters like these:

```
/people?team=design&ascending
```

```elm
Dict.get "team" req.query == Just "design"
Dict.get "ascending" req.query == Just ""
Dict.get "name" req.query == Nothing
```

__Note:__ If you need ever access to the raw URL query string, you can with the `req.url.query` value!

## Raw URLs

If you need the `port`, `hostname`, or anything else it is available at `req.url`, which contains the original [elm/url](https://package.elm-lang.org/packages/elm/url/latest/Url) URL value.

```elm
type alias Url =
    { protocol : Protocol
    , host : String
    , port_ : Maybe Int
    , path : String
    , query : Maybe String
    , fragment : Maybe String
    }
```

This is less common than `req.params` and `req.query`, but can be useful for getting the `hash` at the end of a URL too!

## Getting the current route

The `Request` type also has access to the `Route` value, so you can easily do comparisons agains the current route!

```elm
-- "/"
req.route == Gen.Route.Home_

-- "/about-us"
req.route == Gen.Route.AboutUs

-- "/people/ryan"
req.route == Gen.Route.People_ { name = "ryan" }
```

## Programmatic Navigation

Most of the time, navigation in Elm is as easy as giving an `href` attribute to an anchor tag:

```elm
a [ href "/guide" ] [ text "elm-spa guide" ]
```

Other times, you'll want to do __programmatic navigation__ – navigating to another page after some event completes. Maybe you want to __redirect__ to a sign in page, or head to the __dashboard after signing in successfully__.

In that case we store `req.key` in order to use `Request.pushRoute` or `Request.replaceRoute`. Here's a quick example of what that looks like:

```elm
type Msg = SignedIn User

update : Request Params -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
  case msg of
    SignedIn user ->
      ( model
      , Request.pushRoute Gen.Route.Dashboard req
      )
```

When the `SignedIn` message is fired, this code will redirect the user to the `Dashboard` route.
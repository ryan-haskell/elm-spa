# ryannhg/elm-app
> an experiment for creating single page apps with Elm!


### try it out

1. `npm install`

1. `npm run dev`


### overview

a wrapper around `Browser.application` (that handles routing and page transitions!)

```elm
module Main exposing (main)

import Application exposing (Application)
import Generated.Pages as Pages
import Generated.Route as Route
import Global
import Layouts.Main


main : Application Global.Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    Application.create
        { routing =
            { routes = Route.routes
            , toPath = Route.toPath
            , notFound = Route.NotFound ()
            }
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , layout =
            { view = Layouts.Main.view
            , transition = Application.fade 200
            }
        , pages =
            { init = Pages.init
            , update = Pages.update
            , bundle = Pages.bundle
            }
        }

```

### keep your pages simple

(No need for elm-fork-knife!)

- [`Pages.Index`](./example/src/Pages/Index.elm)

```elm
page =
    Page.static
        { view = view
        }
```

- [`Pages.Counter`](./example/src/Pages/Counter.elm)

```elm
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }
```

- [`Pages.Random`](./example/src/Pages/Random.elm)

```elm
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
```

- [`Pages.SignIn`](./example/src/Pages/SignIn.elm)

```elm
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
```

### _and_ your top level easy to read!

```elm
init appRoute =
    case appRoute of
        Route.Index route ->
            index.init route

        Route.Counter route ->
            counter.init route

        Route.Random route ->
            random.init route
```

( It's like magic, but actually it's just functions. )


### the folder structure

- [Example](./example/src)

```elm
src/
  Api/        -- for backend things
  Components/ -- reusable ui
  Data/       -- types used everywhere
  Layouts/    -- shared views
  Pages/      -- all your pages
  Utils/      -- helpers
  Global.elm  -- shared app state
  Main.elm    -- the entrypoint
```

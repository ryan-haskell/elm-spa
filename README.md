# ryannhg/elm-app
> an experiment for creating single page apps with Elm!


### try it out

1. `npm install`

1. `npm run dev`


### overview

```elm
module Main exposing (main)

import Application exposing (Application)
import Generated.Pages as Pages
import Generated.Route as Route
import Layout as Layout


main : Application () Pages.Model Pages.Msg
main =
    Application.create
        { routing =
            { fromUrl = Route.fromUrl
            , toPath = Route.toPath
            }
        , layout =
            { view = Layout.view
            }
        , pages =
            { init = Pages.init
            , update = Pages.update
            , bundle = Pages.bundle
            }
        }
```

#### supporting code

- [`Generated.Route`](./example/src/Generated/Route.elm)

- [`Generated.Pages`](./example/src/Generated/Pages.elm)

- [`Layout`](./example/src/Layout.elm)

- [`Pages.Homepage`](./example/src/Pages/Homepage.elm) (a static page)

- [`Pages.Counter`](./example/src/Pages/Counter.elm) (a sandbox page)

- [`Pages.Random`](./example/src/Pages/Random.elm) (a static page)
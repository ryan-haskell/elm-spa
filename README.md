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
import Layouts.Main


main : Application () Pages.Model Pages.Msg
main =
    Application.create
        { routing =
            { routes = Pages.routes
            , notFound = Pages.NotFoundRoute ()
            }
        , layout = Layouts.Main.layout
        , pages =
            { init = Pages.init
            , update = Pages.update
            , bundle = Pages.bundle
            }
        }
```

#### supporting code

- [`Generated.Pages`](./example/src/Generated/Pages.elm)

- [`Layouts.Main`](./example/src/Layouts/Main.elm)

- [`Pages.Index`](./example/src/Pages/Index.elm) (a static page)

- [`Pages.Counter`](./example/src/Pages/Counter.elm) (a sandbox page)

- [`Pages.Random`](./example/src/Pages/Random.elm) (a static page)
# ryannhg/elm-spa
> an experiment for creating single page apps with Elm!

__Note__: the API is __still experimental__! (join the conversation on [discourse](https://discourse.elm-lang.org/t/elm-spa-a-tool-for-building-single-page-apps/4597))

### trying it out

```
npm install -g elm-spa
elm-spa init your-project
```

### just using the elm package?


```
elm install ryannhg/elm-spa
```

### overview

```elm
module Main exposing (main)

import Application
import Generated.Pages as Pages
import Generated.Route as Route
import Global


main =
    Application.create
        { ui = Application.usingHtml
        , routing =
            { routes = Route.routes
            , toPath = Route.toPath
            , notFound = Route.NotFound ()
            }
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , page = Pages.page
        }
```

### keep your pages simple

(Instead of making everything an [elm-fork-knife](https://youtu.be/RN2_NchjrJQ?t=2362)!)

- [`Pages.Index`](https://github.com/ryannhg/elm-spa/blob/master/examples/html/src/Pages/Index.elm)

```elm
page =
    Page.static
        { title = title
        , view = view
        }
```

- [`Pages.Counter`](https://github.com/ryannhg/elm-spa/blob/master/examples/html/src/Pages/Counter.elm)

```elm
page =
    Page.sandbox
        { title = title
        , init = init
        , update = update
        , view = view
        }
```

- [`Pages.Random`](https://github.com/ryannhg/elm-spa/blob/master/examples/html/src/Pages/Random.elm)

```elm
page =
    Page.element
        { title = title
        , init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
```

- [`Pages.SignIn`](https://github.com/ryannhg/elm-spa/blob/master/examples/html/src/Pages/SignIn.elm)

```elm
page =
    Page.component
        { title = title
        , init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
```

### while the top level stays easy to read!

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


### run the example

this project comes with an example in [examples/html](https://github.com/ryannhg/elm-spa/blob/master/examples/html).

Here's how to run it:

1. `git clone https://github.com/ryannhg/elm-spa.git && cd elm-spa`

1. `npm install`

1. `npm run dev`

# Beyond HTML

If you're not an CSS ninja, you may have experienced a bad time styling things on the web. Luckily, there's a __wonderful__ project in the Elm community called [Elm UI](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) that makes it possible to create UIs without any HTML or CSS at all!

When you create a page with `elm-spa init`, you can choose between the 3 popular options for building Elm applications:

- `html` - uses [elm/html](https://package.elm-lang.org/packages/elm/html/latest)
- `elm-ui` - uses [mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest)
- `elm-css` - uses [rtfeldman/elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest)

```terminal
elm-spa init my-project --template=elm-ui
```

The `template` option scaffolds out the same starter project, except two files have been modified:

1. `elm.json` has the `mdgriffith/elm-ui` package installed.
2. `Spa/Document.elm` uses `Element` instead of `Html`.

## Using Something Custom

Need something other than the three built-in options? Maybe your company is making a custom design system, and you don't want pages to return `Html` or `Element`, you would rather return a `Ui` type instead.

You can update `src/Spa/Document.elm` with your own custom view library, and the rest of the elm-spa features will still work.

Here's an example with a made up `Ui` library:

```elm
module Spa.Document exposing (Document, map, toBrowserDocument)

import Browser
import Ui exposing (Ui)


type alias Document msg =
  { title : String
  , body : List (Ui msg)
  }


map : (msg1 -> msg2) -> Document msg1 -> Document msg2
map fn doc =
  { title = doc.title
  , body = List.map (Ui.map fn) doc.body
  }


toBrowserDocument : Document msg -> Browser.Document msg
toBrowserDocument doc =
  { title = doc.title
  , body = List.map Ui.toHtml doc.body
  }
```

As long as your library can implement those three exposed functions, you're all set. Your pages can all use your awesome view package!

---

Next up, we'll take a look at [Authentication](/guide/authentication)
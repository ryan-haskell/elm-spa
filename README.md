# elm-spa

[![Build Status](https://travis-ci.org/ryannhg/elm-spa.svg?branch=master)](https://travis-ci.org/ryannhg/elm-spa)

single page apps made easy

### try it out

```
npx elm-spa init new-project
```

### or just install the elm package

```
elm install ryannhg/elm-spa
```

### or run the example

```
cd example && npm start
```

### overview

When you create an app with the [elm/browser](https://package.elm-lang.org/packages/elm/browser/latest) package, you can build anything from a static `Html msg` page to a fully-fledged web `Browser.application`.

`elm-spa` uses that design at the page-level, so you can quickly add new pages to your Elm application!

## the four kinds of pages:

1. __static__ – a page that only renders HTML.
2. __sandbox__ – a page with state.
3. __element__ – a page with side-effects.
4. __component__ – a page with global state.

Check out [the package docs](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/Spa) to learn more!


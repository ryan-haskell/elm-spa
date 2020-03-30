# elm-spa

[![Build Status](https://travis-ci.org/ryannhg/elm-spa.svg?branch=master)](https://travis-ci.org/ryannhg/elm-spa)

## single page apps made easy

When you create an app with the [elm/browser](https://package.elm-lang.org/packages/elm/browser/latest) package, you can build anything from a static `Html msg` page to a fully-fledged web `Browser.application`.

__elm-spa__ uses that design at the page-level, so you can quickly add new pages to your Elm application!

✅ Automatically generate routes and pages

✅ Read and update global state across pages

## static pages

```elm
-- can render a static page
page : Page Flags Model Msg
page =
    Page.static
        { view = view
        }
```

## sandbox pages

```elm
-- can keep track of page state
page : Page Flags Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }
```

## element pages

```elm
-- can perform side effects
page : Page Flags Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
```

## component pages

```elm
-- can read and update global state
page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
```

## easily put together pages!

The reason we return the same `Page` type is to make it super
easy to write top-level `init`, `update`, `view`, and `susbcriptions` functions.

(And if you're using the [official cli tool](https://npmjs.org/elm-spa), this code will be automatically generated for you)

### `init`

```elm
init : Route -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
init route =
    case route of
        Route.Home -> pages.home.init ()
        Route.About -> pages.about.init ()
        Route.Posts slug -> pages.posts.init slug
        Route.SignIn -> pages.signIn.init ()
```

### `update`

```elm
update : Msg -> Model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( Home_Msg msg, Home_Model model ) ->
            pages.home.update msg model

        ( About_Msg msg, About_Model model ) ->
            pages.about.update msg model
      
        ( Posts_Msg msg, Posts_Model model ) ->
            pages.posts.update msg model
      
        ( SignIn_Msg msg, SignIn_Model model ) ->
            pages.signIn.update msg model

        _ ->
            always ( bigModel, Cmd.none, Cmd.none )
```

### `view` + `subscriptions`

```elm
-- handle view and subscriptions in one case expression!
bundle : Model -> Global.Model -> { view : Document Msg, subscriptions : Sub Msg }
bundle bigModel =
    case route of
        Home_Model model -> pages.home.bundle model
        About_Model model -> pages.about.bundle model
        Posts_Model model -> pages.posts.bundle model
        SignIn_Model model -> pages.signIn.bundle model
```

### install the npm package

The [cli tool](https://www.npmjs.com/package/elm-spa) has commands like `elm-spa init`, `elm-spa add`, and `elm-spa build` for
generating your routes and pages for you!

```
npm install -g elm-spa
elm-spa init new-project
```

### install the elm package

If you'd rather define routes and pages by hand,
you can add [the elm package](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest) to your project:

```
elm install ryannhg/elm-spa
```

### rather see an example?

This repo comes with an example project that you can
play around with. Add in some pages and see how it works!

#### html example

```
git clone https://github.com/ryannhg/elm-spa
cd elm-spa/examples/html
npm start
```

#### elm-ui example

```
git clone https://github.com/ryannhg/elm-spa
cd elm-spa/examples/elm-ui
npm start
```

The __elm-spa__ will be running at http://localhost:8000

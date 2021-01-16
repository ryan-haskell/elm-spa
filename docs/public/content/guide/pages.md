# Pages

Every route in your Elm application will be connected to a `Page` file. These files
all have the same general shape:

```elm
module Pages._____ exposing (Model, Msg, page)

page : Shared.Model -> Request Params -> Page Model Msg
```

This section of the guide will introduce you to the __four__ kinds of pages you might
need to use in any Elm application.

> It's important that _every_ page exposes `Model`, `Msg`, and `page`. If any of these three are missing or renamed, the generated code will not work.

## Static pages

If you only need to render some HTML on the page, use `Page.static`:

```elm
Page.static
    { view : View Msg
    }
```

## Sandbox pages

Need to keep track of local state, like the current tab? Check out `Page.sandbox`!

```elm
Page.sandbox
    { init : Model
    , update : Msg -> Model -> Model
    , view : Model -> View Msg
    }
```

## Element pages

If you want to send [HTTP requests](https://guide.elm-lang.org/effects/http.html) or subscribe to other external events, you're ready for `Page.element`:

```elm
Page.element
    { init : ( Model, Cmd Msg )
    , update : Msg -> Model -> ( Model, Cmd Msg )
    , view : Model -> View Msg
    , subscriptions : Model -> Sub Msg
    }
```

## Shared pages

When it comes time to update the global state shared from page to page, you can upgrade to `Page.shared`:

```elm
Page.shared
    { init : ( Model, Cmd Msg, List Shared.Msg )
    , update : Msg -> Model -> ( Model, Cmd Msg, List Shared.Msg )
    , view : Model -> View Msg
    , subscriptions : Model -> Sub Msg
    }
```
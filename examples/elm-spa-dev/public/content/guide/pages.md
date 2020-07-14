# Pages

By default, there are four kinds of pages you can create with __elm-spa__. Always choose the simplest one for the job!

## Static

A simple, static page that just returns a view.

```elm
page : Page Params Model Msg
page =
  Page.static
    { view = view
    }
```

```elm
view : Url Params -> Document Msg
```

## Sandbox

A page that needs to maintain local state.

```elm
page : Page Params Model Msg
page =
  Page.sandbox
    { init = init
    , update = update
    , view = view
    }
```

```elm
init : Url Params -> Model
update : Msg -> Model -> Model
view : Model -> Document Msg
```

## Element

A page that can make side effects with `Cmd` and listen for updates as `Sub`.

```elm
page : Page Params Model Msg
page =
  Page.element
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }
```

```elm
init : Url Params -> ( Model, Cmd Msg )
update : Msg -> Model -> ( Model, Cmd Msg )
view : Model -> Document Msg
subscriptions : Model -> Sub Msg
```

## Application

A page that can read and write to the shared model.

```elm
page : Page Params Model Msg
page =
  Page.application
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    , save = save
    , load = load
    }
```

```elm
init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
update : Msg -> Model -> ( Model, Cmd Msg )
view : Model -> Document Msg
subscriptions : Model -> Sub Msg
save : Model -> Shared.Model -> Shared.Model
load : Shared.Model -> Model -> ( Model, Cmd Msg )
```

Because `save` and `load` are new constructs, here's an explanation of how they work:

#### __save__ 
Anytime you update the `Model` with `init` or `update`, `save` is automatically called (by `Main.elm`). This allows you to persist local state to the entire application.

#### __load__
Much like `update`, the `load` function gets called whenever the `Shared.Model` changes. This allows you to respond to external changes to update your local state or send a command!

---

Let's take a deeper look at [Shared](/guide/shared) together.
# the cli tool
> you _could_ type everything out... or...

## so the package makes wiring things up consistent

And you know what loves consistency? __Computers!__

So if you don't want to type out this:

```elm
type Model
  = Foo Foo.Model
  | Bar Bar.Model
  | Baz Baz.Model

type Msg
  = Foo Foo.Msg
  | Bar Bar.Msg
  | Baz Baz.Msg

init route_ =
  case route_ of
    Route.Foo route -> foo.init route
    Route.Bar route -> bar.init route
    Route.Baz route -> baz.init route

update msg_ model_ =
  case ( msg_, model_ ) of
    ( FooMsg msg, FooModel model ) -> foo.update msg model
    ( BarMsg msg, BarModel model ) -> bar.update msg model
    ( BazMsg msg, BazModel model ) -> baz.update msg model
    _ -> Page.keep model_

bundle model_ =
  case model_ of
    FooModel model -> foo.bundle model
    BarModel model -> bar.bundle model
    BazModel model -> baz.bundle model
```

It was pretty easy to make a script to type that for you:

```
elm-spa generate
```

And it will look at the files in your `src/Pages` folder:

```elm
src/
  Pages/
    Foo.elm
    Bar.elm
    Baz.elm
```

And even generate the routes based on the module name:

```elm
-- routes
/foo -> Foo.elm
/bar -> Bar.elm
/baz -> Baz.elm
```


### Hooray!

This CLI tool just benefits from the consistent API the package uses.

If you'd rather use `ryannhg/elm-spa` without the CLI tool- that's cool with me! 😎

# the cli
> so you _could_ type everything out... or...


### are your hands tired? 😩

Maybe it's because you've been typing out boilerplate!

Using `ryannhg/elm-spa` makes the things you type more _consistent_, but the repetitive bits might get boring after a while...

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

### sounds like a job for a robot! 🤖

it seemed like a good idea to write something to type all that for you. so i did! ❤️

it looks at the files in your `src/Pages` folder:

```elm
src/
  Pages/
    Foo.elm
    Bar.elm
    Baz.elm
```

...types out all that stuff...

```elm
module Generated.Pages exposing (Model, Msg, page)

-- ...

type Model
  = Foo Foo.Model
  | Bar Bar.Model
  | Baz Baz.Model

-- ... everything else!
```

...and infers the routes based on the filenames!

```elm
module Generated.Route exposing (Route, routes)

-- ... route stuff

routes =
  [ Route.path "/foo" Route.Foo
  , Route.path "/bar" Route.Bar
  , Route.path "/baz" Route.Baz
  ]
```


### (the choice is yours) ⚖️

This CLI tool is just a companion tool for the Elm package. Totally optional!

If you'd rather use [`ryannhg/elm-spa`](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/) without the CLI tool- that's cool with me!


### thinking about trying it out? 🤔

If you already have [NodeJS](https://nodejs.org/en/), getting started is easy!

Just install [the npm package](https://www.npmjs.com/package/@ryannhg/elm-spa) (it's got zero dependencies, bb)

```
npm install -g @ryannhg/elm-spa
```

and make a new project somewhere:

```
elm-spa init my-new-app
cd my-new-app
npm install
npm run dev
```

Your app will be at [http://localhost:1234](http://localhost:1234)


### you've got this! 💪

Go build something awesome! 🚀

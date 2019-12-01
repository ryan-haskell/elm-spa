---
{ "title": "elm-spa add"
, "description": "create new pages from the command line."
}
---

<iframe></iframe>

### typing is for nerds!

Once you have created a new project with [elm-spa init](./init), you can use the `elm-spa add` command like this:

```bash
npx elm-spa add static Example
```

That command will create a file at `src/Pages/Example.elm` that looks something like this:

```elm
module Pages.Example exposing (Model, Msg, page)

-- imports

page : Spa.Page Model Msg
page =
  Page.static
    { title = always "Example"
    , view = always view
    }

view : Html Msg
view =
  text "Example"
```

It's just a bit of boilerplate to get you started on creating your next thing.

### creating more complex pages

You can create any of the four page types with this command!

```bash
npx elm-spa add static Example
```

```bash
npx elm-spa add sandbox Example
```

```bash
npx elm-spa add element Example
```

```bash
npx elm-spa add component Example
```


### is that it?

pretty much! but there's another cool perk when you use the `elm-spa add` command:

it will automatically create layouts for you too!

```bash
npx elm-spa add element Foo.Bar

elm-spa created 2 files:

  /code/your-project/src/Layouts/Foo.elm
  /code/your-project/src/Pages/Foo/Bar.elm

```

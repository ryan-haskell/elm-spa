---
{ "title": "elm-spa init"
, "description": "create a new project from the command line."
}
---

<iframe></iframe>

### the cli is your pal.

If you want to create a new project, you can use the `elm-spa init` command like this:

```bash
npx elm-spa init your-project
```

Here, you can replace `your-project` with whatever you like!


### choose your ui

By default, running `elm-spa init` will use [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/),
a package that lets us build web UIs _without HTML or CSS_.

It's pretty neat.

If you'd like to use the standard [elm/html](https://package.elm-lang.org/packages/elm/html/latest/)
library, you can provide the `--ui` flag like this:

```bash
npx elm-spa init --ui=Html your-project
```

This creates an `elm-spa.json` file with `Html` set as the `ui` option in your
project folder.

That means `elm-spa add` will generate `import Html` instead of `import Element`
for all your new pages!

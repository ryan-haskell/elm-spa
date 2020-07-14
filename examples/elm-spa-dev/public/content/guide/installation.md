# Installation

You can install `elm-spa` via [npm](https://nodejs.org/):

```terminal
npm install -g elm-spa@latest
```

Now, you can run `elm-spa` from the terminal!

## Hello, CLI

If you're ever stuck- run `elm-spa help`, the CLI comes with __built-in documentation__!

```terminal
elm-spa help

  elm-spa – version 5.0.0

  elm-spa init – create a new project
  elm-spa add – add a new page
  elm-spa build – generate routes and pages automatically

  elm-spa version – print version number
```

## elm-spa init

The `init` command scaffolds a new __elm-spa__ project. 

```terminal
elm-spa init
```

When you run the command, you will be presented with an interactive dialogue to choose between:

1. The UI Library ([elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest), [elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest), or [html](https://package.elm-lang.org/packages/elm/html/latest))
2. The folder name

Each project works and behaves the same way, but `elm.json`, `Spa.Document`, and the `Shared.view` are updated to use the UI library of your choice.

## elm-spa add

You can add more pages to an existing __elm-spa__ project with the `elm-spa add` command. 

```terminal
elm-spa add
```

Just like the last command, an interactive dialogue will ask you two things:

1. The type of page (static, sandbox, element, or application)
1. The page's module name

The meaning of each of the page types will be explained in the [Pages](/guide/pages) section!

__Note:__ Running the `elm-spa add` command will overwrite the contents of the existing file, so don't use it for upgrading an existing page.

## elm-spa build

This command does the automatic code generation for you. If you follow the naming conventions outlined in the next section, this is where elm-spa saves you time!

```terminal
elm-spa build
```

The generated code is in the `src/Spa/Generated` folder! Feel free to take a look, it's human readable Elm code!

__No need to call this!__ The project created by `elm-spa init` actually calls this under the hood.

Just use `npm start`, and you're good!

---

Next, let's talk about the [Routing](/guide/routing)!

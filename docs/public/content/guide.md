# Guide

Welcome to __elm-spa__, a framework for building web applications with [Elm](https://elm-lang.org)!
If you are new to Elm, you should check out [the official guide](https://guide.elm-lang.org), which
is a great introduction to the language.

The goal of _this_ guide is to help you solve common problems you might run into with real world single-page web applications.

## Features

Here are a few benefits to using elm-spa:
1. __Automatic routing__ - routes for your web app are automatically generated based on file names. No need to maintain URL routing logic or wire pages together manually.
1. __Simple shared state__ - comes with a straightforward way to share data within and between pages. You can also make pages as simple or complex as you need!
1. __Zero configuration__ - Includes a hot-reloading dev server, build tool, and everything you need in one CLI tool! No need for webpack, uglify, or other NPM packages.


## Quickstart

### Creating your first project

You can create a new __elm-spa__ project from scratch my creating a new folder:

```terminal
mkdir my-new-project && cd my-new-project
```

And then running this command in your terminal:

```terminal
npx elm-spa new
```

This will create a brand new project in the `my-new-project` folder! It should only contain these three files:

```bash
my-new-project/
 - .gitignore      # folders to ignore in git
 - elm.json        # project dependencies
 - src/
 - public/
    - index.html   # entrypoint to your application
```

### Running the dev server

Running this command will start a development server at `http://localhost:1234`:

```terminal
npx elm-spa server
```

### Adding your first page

To add a homepage, run the `elm-spa add` command:

```terminal
npx elm-spa add /
```

This will create a new page at `./src/Pages/Home_.elm`. Try editing the text in that file's `view` function, it will automatically change in the browser!


## Installation

So far, we've been using the [npx command](https://www.npmjs.com/package/npx) built into Node.js to run the `elm-spa` CLI. If we would rather use the CLI without this prefix, we can install __elm-spa__ globally:

```terminal
npm install -g elm-spa@latest
```

This will ensure we have the latest version of elm-spa available in our terminal. You can make sure it works by calling `elm-spa` directly:

```terminal
elm-spa help

elm-spa – version 6.0.0

Commands:
elm-spa new . . . . . . . . .  create a new project
elm-spa add <url> . . . . . . . . create a new page
elm-spa build . . . . . . one-time production build
elm-spa watch . . . . . . .  runs build as you code
elm-spa server  . . . . . . start a live dev server

Visit https://next.elm-spa.dev for more!
```

If you see this message, you can run all the CLI commands without needing to prefix them with `npx`!

__Next up:__ [The CLI](/guide/cli)
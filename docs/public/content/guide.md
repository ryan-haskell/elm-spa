# Guide

Welcome to __elm-spa__, a framework for building web applications with [Elm](https://elm-lang.org)!
If you are new to Elm, you should check out [the official guide](https://guide.elm-lang.org), which
is a great introduction to the language.

The goal of this guide is to help you solve any problems you might run into when building real world single-page web applications.

## Features

Here are some of the benefits for using __elm-spa__:
1. __Automatic routing__ - routes for your web app are automatically generated based on file names. No need to maintain URL routing logic or wire pages together manually.
1. __User authentication__ - provides an easy way to guarantee certain pages are only visible to signed-in users. You can check out the [user authentication](/examples/04-authentication) example for more details!
1. __Zero configuration__ - Includes a hot-reloading dev server, build tool, and everything you need in one CLI tool! No need for webpack, uglify, or other NPM packages.


## Quickstart

If you already have [NodeJS](https://nodejs.org) installed, getting started with __elm-spa__ is easy:

```terminal
npx elm-spa new
```

This will create a new project in the current folder. Even better: this command only creates __three__ files:

```bash
elm.json               # project dependencies
src/Pages/Home_.elm    # our homepage
public/index.html      # entrypoint to your application
```

Let's use __elm-spa__ to spin up a dev server:

```terminal
npx elm-spa server
```

If you see "Hello, world!" at [http://localhost:1234](http://localhost:1234), you did it!

## Installation

So far, we've been using [npx](https://www.npmjs.com/package/npx) so we can run __elm-spa__ directly from the command line. If you'd like to run commands from the terminal without the `npx` prefix, you can install __elm-spa__ like this:

```terminal
npm install -g elm-spa@latest
```

To verify the install succeeded, run `elm-spa help` from your terminal:

```terminal
elm-spa help

elm-spa – version 6.0.0

Commands:
elm-spa new . . . . . . . . .  create a new project
elm-spa add <url> . . . . . . . . create a new page
elm-spa build . . . . . . one-time production build
elm-spa server  . . . . . . start a live dev server

Other commands:
elm-spa gen . . . . generates code without elm make
elm-spa watch . . . .  runs elm-spa gen as you code

Visit https://elm-spa.dev for more!
```

That output means you can run the `elm-spa` CLI without needing `npx`

---

__Next up:__ [The CLI](/guide/01-cli)

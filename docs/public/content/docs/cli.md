# The CLI

At the end of the last section, we installed the __elm-spa__ CLI using [npm](https://npmjs.org) like this:

```terminal
npm install -g elm-spa@latest
```

This gave us the ability to run a few commands:

1. [__elm-spa new__](#elm-spa-new) - creates a new project
1. [__elm-spa server__](#elm-spa-server) - runs a dev server as you code
1. [__elm-spa watch__](#elm-spa-watch) - builds as you code
1. [__elm-spa build__](#elm-spa-build) - one-time production build
1. [__elm-spa add__](#elm-spa-add) - adds a page to an existing project

What do these do? This section of the guide dives into more detail on each command!

## elm-spa new

When you want to create a new project, you can use the `elm-spa new` command. This creates a new project in the current folder:

```terminal
elm-spa new
```

```bash
New project created in:
/Users/ryan/code/my-new-app
```

This command only creates __three__ files:

Filename | Description
--- | ---
`elm.json` | Keeps track of [Elm packages](https://package.elm-lang.org).
`src/Pages/Home_.elm` | The project's homepage.
`public/index.html` | The HTML entrypoint to the app.

## elm-spa server

The first thing you'll want to do after creating a new project is try it out in the browser! The `elm-spa server` is all you need to see your app in action:

```terminal
elm-spa server
```

This will start a development server for your project at [http://localhost:1234](http://localhost:1234).

When we edit our code, `elm-spa server` automatically compiles your application.

## elm-spa watch

If you want the automatic compilation on change, but don't need a HTTP server, you can use the `elm-spa watch` command:

```terminal
elm-spa watch
```

This will automatically generate code and compile your Elm files on save, but without the server. This is a great command to combine __elm-spa__ with another tool like [Parcel](https://parceljs.org/elm.html).


## elm-spa build

The `server` and `watch` commands are great for development, but for __production__, we'll want the `elm-spa build` command.

```terminal
elm-spa build
```

This compiles your app into __an optimized and minified JS file__. This makes it great for serving your application in the real world!


## elm-spa add

You can add new pages to your app with the `elm-spa add` command:

```terminal
elm-spa add /contact
```

This creates a new file at `src/Pages/Contact.elm`. If you visit [http://localhost:1234/contact](http://localhost:1234/contact) in the browser, you'll see a new page with the text `"Contact"` displayed.

### adding other pages

Here are a few examples of other routes you can create with the add command

```bash
elm-spa add /              # src/Pages/Home_.elm
elm-spa add /settings      # src/Pages/Settings.elm
elm-spa add /people/:id    # src/Pages/People/Id_.elm
```

We'll cover this in more detail in the [routing section](./routing)

### using page templates

The `elm-spa add` command also accepts an optional `template` argument too for common
pages you might create.

```bash
elm-spa add /example static
elm-spa add /example sandbox
elm-spa add /example element
```

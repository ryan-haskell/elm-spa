# Hello, world!

__Source code__: [GitHub](https://github.com/ryannhg/elm-spa/tree/main/examples/01-hello-world)

Welcome to __elm-spa__! This guide is a breakdown of the simplest project you can make: the "Hello, world!" example.

### Installation

In case you are starting from scratch, you can install __elm-spa__ via NPM:

```terminal
npm install -g elm-spa@latest
```

### Creating a project

This will allow you to create a new project using the following commands:

```terminal
elm-spa new
```




When we ran `elm-spa new`, only __three__ files were created:

- __public/index.html__ - the entrypoint for our web app.
- __src/Pages/Home\_.elm__ - the homepage.
- __elm.json__ - our project dependencies.

### Running the server

With only these files, we can get an application up-and-running:

```terminal
elm-spa server
```

This runs a server at [http://localhost:1234](http://localhost:1234). If everything worked, you should see this in your browser:

![A page that reads "Hello World"](/content/images/01-hello-world.png)


### The entrypoint

Earlier, I mentioned that `public/index.html` was the "entrypoint" to our web app. Let's take a look at that file:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
  <script src="/dist/elm.js"></script>
  <script> Elm.Main.init() </script>
</body>
</html>
```

This HTML file defines some standard tags, and then runs our Elm application. Because our Elm compiles to JavaScript, the `elm-spa server` command generates a `/dist/elm.js` file anytime we make changes.

Once we import that with a `<script>` tag, we can call `Elm.Main.init()` to startup our Elm application.

### The homepage

Next, let's look at `src/Pages/Home_.elm`:

```elm
module Pages.Home_ exposing (view)

import Html
import View exposing (View)


view : View msg
view =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }
```

This `view` function has two parts:
- `title` - the tab title
- `body` - the HTML we render, with [elm/html](https://package.elm-lang.org/packages/elm/html/latest/)

Try changing `"Hello, world!"` to something else– it should replace what you see in the browser. 

The `elm-spa server` you ran is designed to __automatically refresh__ when your Elm code changes, but you _may_ need to refresh manually to see the change.

### The dependencies

The `elm.json` tracks all our project dependencies. Elm packages are available at [package.elm-lang.org](https://package.elm-lang.org/). Here's our initial file:

```js
{
    "type": "application",
    "source-directories": [
        "src",
        ".elm-spa/defaults",
        ".elm-spa/generated"
    ],
    "elm-version": "0.19.1",
    "dependencies": { /* ... */ },
    "test-dependencies": { /* ... */ }
}
```

Normally, `source-directories` in Elm projects only contain the `"src"` folder, but __elm-spa__ projects automatically generate code and provide some default files.

When we start getting into more advanced guides, we can move files from `.elm-spa/defaults` into our `src` folder. That will track them in git, and let us make changes.

The files in `.elm-spa/generated` should not be changed, so they are stored in a separate folder. Feel free to browse these if you are curious, they are just normal Elm code.


### The .gitignore

By default, a `.gitignore` file is generated to promote best practices when working with __elm-spa__ and your git repo:

```
.elm-spa
elm-stuff
dist
```

Notice that the `.elm-spa` folder is __ignored from git__. You shouldn't push any generated __elm-spa__ code to your repo. Instead, use commands like `elm-spa build` to reliably regenerate these files during deployments.

```terminal
elm-spa build
```

This command will also minify your `/dist/elm.js` file so it's production ready.


---

__Next up:__ [Pages](./02-pages)
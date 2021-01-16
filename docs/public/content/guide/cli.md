# The CLI

The [official __elm-spa__ CLI tool](https://npmjs.org/elm-spa) has a few commands to help you build single page applications. As we saw in [the previous section](/guide/overview), you can use the CLI from your terminal by running:

```terminal
npm install -g elm-spa@latest
```

At any time running `elm-spa` or `elm-spa help` will show you the available commands:

```
elm-spa new . . . . . . . . .  create a new project
elm-spa add <url> . . . . . . . . create a new page
elm-spa build . . . . . . one-time production build
elm-spa watch . . . . . . .  runs build as you code
elm-spa server  . . . . . . start a live dev server
```

## Creating new projects

The `new` command creates a new project in the current folder:

```terminal
elm-spa new
```

This command will only create a few files, so don't worry about getting overwhelmed with new files in your repo! Other than a `.gitignore`, there are only 2 new files created.

File | Description
--- | ---
`elm.json` | Your project's dependencies.
`src` | An empty folder for your Elm code.
`public/index.html` | The entrypoint to your application.

```
your-project/
  - elm.json
  - src/
  - public/
     - index.html
```

The `public` folder is a place for static assets! For example, a file at `./public/style.css` will be available at `/style.css` in your web browser.

## Adding pages

The next section will dive into deeper detail, but __elm-spa__ directly maps file names to URLs.

URL | File Location
--- | ---
`/` | `src/Pages/Home_.elm`
`/about-us` | `src/Pages/AboutUs.elm`
`/people/ryan` | `src/Pages/People/Ryan.elm`

The `elm-spa add` command makes it easy to scaffold out new pages in your application!

### Adding a homepage

Here's how you can add a homepage with the `elm-spa add` command:

```terminal
elm-spa add /
```

### Adding static pages

You can add [static routes](/guide/basics/routing#static-routes) with the add command also:

```terminal
elm-spa add /settings
```

This command will create a new page at `src/Pages/Settings.elm`, and be available at `/settings`.

### Adding dynamic pages

In the [next section](/guide/basics/routing), you'll learn more about static and dynamic pages, which can handle dynamic URL parameters to make life easy. For example, if we wanted a "Person Detail" page, we could do something like this:

```terminal
elm-spa add /people/:name
```

This creates a new page at `src/Pages/People/Name_.elm`. The underscore (`_`) at the end of the filename indicates a __dynamic__ route! This dynamic route handles requests to pages like these:

URL | Params
--- | ---
`/people/ryan` | `{ name = "ryan" }`
`/people/erik` | `{ name = "erik" }`
`/people/alexa` | `{ name = "alexa" }`

The name of the file (`Name_.elm`) determines the variable name.

### Removing pages

Removing pages with __elm-spa__ is as simple as __deleting the file__

```terminal
rm src/Pages/Settings.elm
```

You can do this however you prefer, but there isn't an `elm-spa remove` command in the CLI.


## Developing locally

The __elm-spa__ CLI comes with a hot-reloading development server built in. As you save files in the `src` and `public` folders, your local site will automatically refresh.

```terminal
elm-spa server
```

By default, the server will start on port 1234. You can specify a different port with the `PORT` environment variable:

```terminal
PORT=8000 elm-spa server
```

__Note:__ The `server` command is not designed for production use! To 

### Prefer webpack or parcel?

You can use the `watch` command to build assets without running the development server. This will build your application, and allow you to use something like [Parcel](https://parceljs.org/elm.html) or [webpack](https://github.com/elm-community/elm-webpack-loader).

```terminal
elm-spa watch
```

## Building for production

When you are ready you ship your application, the `build` command will create a minified and optimized JS file for production.

```terminal
elm-spa build
```

For more information about deployments and hosting, you should check out the [Hosting & Development](/guide/hosting) section!
module Pages.Docs exposing (Model, Msg, page)

import Components.Hero as Hero
import Element exposing (..)
import Generated.Params as Params
import Spa.Page
import Ui
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Docs Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "docs | elm-spa"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    Ui.sections
        [ Hero.view
            { title = "docs"
            , subtitle = "a reference for elm-spa"
            , links = []
            }
        , Ui.markdown """
### new to elm-spa?

this is a reference to help answer common questions, but if you're new to
elm-spa, I'd check out [the official guide](/guide) instead!

### table of contents

1. [installation & setup](#installation-setup)
1. [project structure](#project-structure)
1. [elm.json](#elm-json)
1. [elm-spa.json](#elm-spa-json)
1. [package.json](#package-json)
    1. [`npm start`](#-npm-start-)
    1. [`npm run dev`](#-npm-run-dev-)
    1. [`npm run build`](#-npm-run-build-)
1. [components](#src-components)
1. [layouts](#src-layouts)
1. [pages](#src-pages)
1. [global.elm](#src-global-elm)
1. [layout.elm](#src-layout-elm)
1. [main.elm](#src-main-elm)
1. [ports.elm](#src-ports-elm)
1. [transitions.elm](#src-transitions-elm)
1. [`elm-spa`](#-elm-spa-)
    1. [`elm-spa init`](#-elm-spa-init-)
    1. [`elm-spa add`](#-elm-spa-add-)
    1. [`elm-spa build`](#-elm-spa-build-)
1. [deploying](#deploying)

### installation & setup

If you have the latest version of [NodeJS](https://nodejs.org) installed, then
you're ready to run this command:

```
npx elm-spa init our-project
```

That command will create a new folder called `our-project` and have everything 
you need to get started with __elm-spa__!

```
cd our-project
npm start
```

Running those two commands next will start a web server at http://localhost:1234

__After that you should be all set!__

### project structure

your new elm-spa project should look something like this

```elm
our-project/
  elm.json          -- your elm dependencies
  elm-spa.json      -- your elm-spa config
  package.json      -- your node dependencies
  src/
    Components/...  -- for reusable ui
    Layouts/...     -- common ui around pages
    Pages/...       -- all routes in the app
    Utils/...       -- helpers around types
    Global.elm      -- shared state across pages
    Layout.elm      -- app-level view
    Main.elm        -- the Elm app entrypoint
    Ports.elm       -- for communication with JS
    Transitions.elm -- make navigation pretty
  public/
    index.html      -- web server entrypoint
    styles.css      -- for custom styles
    ports.js        -- for communication with JS
```

(_Let's break those files down together!_)

### elm.json

when you run `elm install`, this is where the package and version you've installed
are saved.

Using an `elm.json` allows us to track dependencies without needing to commit the
`elm-stuff` folder to the git repo.


### elm-spa.json

when you run `elm-spa add`, this tells __elm-spa__ if you'd rather use `Html`,
`Element`, or another elm module for views in the app.

### package.json

this is where your node dependencies (like `elm`, `elm-live`, and `elm-spa`) are
tracked.

this is also where `elm-spa init` for the npm scripts you can run

#### `npm start`

Runs `npm install`, and runs a dev web server at http://localhost:1234.

Saving files will automatically call `elm-spa build` and update the browser window
for you!

#### `npm run dev`

This command is the same as `npm start`, but doesn't run `npm install` for you.

#### `npm run build`

This builds your Elm app, and makes sure `elm-spa` generates the correct files for you.

Useful when [deploying a free static site on Netlify](#deploying).

### src/Components

How you reuse your UI is ultimately up to you!

this folder is a cool place to put something like a `Hero` that you want to
reuse from page to page.


##### `src/Components/Hero.elm`
```elm
module Components.Hero exposing (Options, view)

import Html exposing (..)
import Html.Attributes as Attr exposing (class)

type alias Options =
    { title : String
    , subtitle : String
    }

view : Options -> Html msg
view options =
    div [ class "hero" ]
        [ h1 [ class "hero__title" ] [ text options.title ]
        , h2 [ class "hero__subtitle" ] [ text options.subtitle ]
        ]
```

I've started getting in the habit of creating a file called `Ui.elm` that exposes
reused UI elements like this:

##### `src/Ui.elm`
```elm
module Ui exposing (hero)

import Html exposing (..)
import Html.Attributes as Attr exposing (class)

hero :
    { title : String
    , subtitle : String
    } -> Html msg
hero options =
    div [ class "hero" ]
        [ h1 [ class "hero__title" ] [ text options.title ]
        , h2 [ class "hero__subtitle" ] [ text options.subtitle ]
        ]
```

Choose the __simplest__ solution that gets the job done– making a new file for
every piece of UI isn't always the best idea!


### src/Layouts

When using `elm-spa add`, these files automatically wrap pages within the same route.

For example:

```elm
src/
  Pages/
    Top.elm
    AboutUs.elm
    Docs/
      Foo.elm
      Bar.elm
      Baz.elm
  Layouts/
    Docs.elm
```

##### `src/Layouts/Docs.elm`
```elm
module Layouts.Docs exposing (view)

import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Html msg
view { page } =
    div [ class "docs__layout" ]
        [ text "I'm a sidebar"
        , page
        ]
```

The paths:
- `/docs/foo`
- `/docs/bar`
- `/docs/baz`

will _all_ render with the `"I'm a sidebar"`, whereas `/` and `/about-us` will
not.

The file name in `src/Layouts` __should always__ match the folder name in `src/Pages`.

(The CLI tool takes care of this automatically, so no worries)

### src/Pages

The files in this folder map directly to the URLs in your routes. 
Here's an example:

```elm
src/
  Pages/
    Top.elm
    AboutUs.elm
    Careers.elm
    AboutUs/
      OurMission.elm
      Team.elm
    Work/
      Top.elm
      Testimonials.elm
      Dynamic.elm
    Posts/
      Dynamic/
        Authors/
          Dynamic.elm
```

Routes generated:

- `/`
- `/about-us`
- `/careers`
- `/about-us/our-mission`
- `/about-us/team`
- `/work`
- `/work/testimonials`
- `/work/:param1`
- `/posts/:param1/authors/:param2`

Nested, dynamic parameters are supported– and will be passed into your page's 
`init` function as a record (Like `{ param1 : String }`).

Most of the time, just name the file and folder the route you'd like.

```elm
./src/Pages/Maybe/Something/LikeThis.elm
-- http://localhost:1234/maybe/something/like-this
```

(The routes are lowercased and hyphenated for you)

The `Top.elm`, `Dynamic.elm`, and `Dynamic/` folders are special, and are
documented below!

##### Using `Top.elm`

Creating a file called `Top.elm` will put the page in that folder.
Here's what I mean:

```elm
src/
  Pages/
    Top.elm
    AboutUs/
      Top.elm
    Top/
      Top.elm
```

Will result in these three routes:

- `/`
  maps to `Top.elm`

- `/about-us`
  maps to `AboutUs/Top.elm`

- `/top`
  maps to `Top/Top.elm`

##### Using `Dynamic.elm` and `Dynamic/`

Creating a file called `Dynamic.elm` will use your page for any string that comes
in. Here's what I mean:

```elm
src/
  Pages/
    Dynamic.elm
    AboutUs/
      Dynamic.elm
    Dynamic/
      Dynamic.elm
```

Will result in these three routes:

- `/apples`
  maps to `Dynamic.elm`

- `/bananas`
  maps to `Dynamic.elm`

- `/cherries`
  maps to `Dynamic.elm`

- `/about-us/apples`
  maps to `AboutUs/Dynamic.elm`

- `/about-us/bananas`
  maps to `AboutUs/Dynamic.elm`

- `/about-us/cherries`
  maps to `AboutUs/Dynamic.elm`

- `/foo/apples`
  maps to `Dynamic/Dynamic.elm`

- `/foo/bananas`
  maps to `Dynamic/Dynamic.elm`

- `/foo/cherries`
  maps to `Dynamic/Dynamic.elm`

- `/bar/apples`
  maps to `Dynamic/Dynamic.elm`

- `/bar/bananas`
  maps to `Dynamic/Dynamic.elm`

- `/bar/cherries`
  maps to `Dynamic/Dynamic.elm`

### src/Global.elm

This file defines and manages state across your application.

It provides a `Model`, `Msg`, `init`, `update`, and `subscriptions` to handle
shared state between pages, and has access to things like

```elm
navigate : Route -> Cmd msg
```

for programmatic navigation between pages.


### src/Layout.elm

Just like `src/Layouts/*.elm` this file wraps around pages, but at the top-level.

If you want a header and footer that are visible on _every_ page, this would be a great place to
put that code!

### src/Main.elm

This is the entrypoint to the Elm app. It calls `Spa.create` and passes it all the
configuration for the project, so the package can handle routing, transitions and
all that other tedious stuff.

### src/Ports.elm

Need to use JavaScript to do something! This file is the only `port module` in
the app, and exposes functions for sending `Cmd msg` to `./public/ports.js`.

You can also add in ports for receiving `Sub msg` from JS in this file.

(An example of using this for `console.log` is provided when you run `elm-spa init`)

### src/Transitions.elm

Page transitions are what make Elm and other client side routing libraries look awesome.

This file uses the `Spa.Transitions` module in `ryannhg/elm-spa` to describe:

- `layout` - how you want the app to appear on page load

- `page` - how you want pages to transition out and into view

- `pages` - if there are any routes you'd like to do something different 
(like how the `/guide` sidebar doesn't fade in/out on route change)

### `elm-spa`

This guide will use the `npx elm-spa` syntax, which doesn't require you to run
that command.

the CLI tool is available on npm and can be installed globally:

```
npm install --global elm-spa
```

#### Forgot a command?

You can type this into your terminal to get inline docs:

```
npx elm-spa help
```

### `elm-spa init`

This command creates a new elm-spa project in a folder of your choosing.
For example:

```
npx elm-spa init my-project
```

will create a new folder called "my-project" with everything you need!

If you'd rather work with Html instead of Elm UI, include the `--ui=` flag:

```
npx elm-spa init --ui=Html my-project
```


### `elm-spa add`

You can use the `elm-spa add` command to add four kinds of pages:

If you'd like to create a new page at `/about-us`, run one of these commands:

```
npx elm-spa add static AboutUs
npx elm-spa add sandbox AboutUs
npx elm-spa add element AboutUs
npx elm-spa add component AboutUs
```

Want to create a page at `/something/like/this`?

```
npx elm-spa add static Something.Like.This
npx elm-spa add sandbox Something.Like.This
npx elm-spa add element Something.Like.This
npx elm-spa add component Something.Like.This
```

Notice we use the module name casing here `Foo.Bar.Baz` and __not__ the URL case (`/foo/bar/baz`)
in the `add` command.

##### Remember:

Choose the __simplest page__ for the job. If you need a more complex page later,
refactoring with `elm-spa` is a breeze!

#### Static

Creating pages that don't manage state:

```elm
page =
    Page.static
        { title = always title
        , view = always view
        }

title : String
view : Html Never
```

#### Sandbox

Creating pages that __do__ manage state:

```elm
page =
    Page.sandbox
        { title = always title
        , init = always init
        , update = always update
        , view = always view
        }

title : String
init : Params -> Model
update : Msg -> Model -> Model
view : Model -> Html Msg
```

#### Element

Can send `Cmd msg` and receive `Sub msg` (for pages that have side effects).

```elm
page =
    Page.element
        { title = always title
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }

title : String
init : Params -> ( Model, Cmd Msg )
update : Msg -> Model -> ( Model, Cmd Msg )
subscriptions : Model -> Sub Msg
view : Model -> Html Msg
```

#### Component

An `element` that can send `Cmd Global.Msg` to affect the shared state across pages.

```elm
page =
    Page.component
        { title = always title
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }

title : String
init : Params -> ( Model, Cmd Msg, Cmd Global.Msg )
update : Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
subscriptions : Model -> Sub Msg
view : Model -> Html Msg
```

#### what's up with `always`?

Each page type can access the `Global.Model`, current `Route`, and other context by
omitting the `always` function.

By default, `elm-spa add` will include these to keep your pages simple. Remove the
always if you need access on a given page!

Here's a quick visual example with `Page.sandbox`:

```elm
page =
    Page.sandbox
        { title = always title
        , init = always init
        , update = always update
        , view = view -- omitting "always"
        }

title : String
init : Params -> Model
update : Msg -> Model -> Model
view : PageContext -> Model -> Html Msg
```

Now the `view` function has access to the
[PageContext](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/Spa-Types#PageContext)

### `elm-spa build`

this command is included in the package.json created by `elm-spa init`.

It generates your code in the `elm-stuff/.elm-spa` folder, which should automatically
be ignored by the `.gitignore` file.

### deploying

if you're ready to share your app with the world, tweet me about it at [@ryan_nhg](https://twitter.com/Ryan_NHG)– I'd love to check it out!

The `elm-spa init` command sets you up to easily deploy to Netlify, a free, fast, and insanely simple way to host a website.

(This site is hosted on there too!)

[Netlify](https://www.netlify.com) has great docs on how to get started, but here are some things you'll need from me:

- __Build command__: `npm run build`

- __Publish directory__: `public`

"""
        ]

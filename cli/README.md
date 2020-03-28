# elm-spa 

[![Build Status](https://travis-ci.org/ryannhg/elm-spa.svg?branch=master)](https://travis-ci.org/ryannhg/elm-spa)

## single page apps made easy

this is the cli tool for [the ryannhg/elm-spa package](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest). 

It comes with a few commands to help you build single page applications in Elm!

## installation

```
npm install -g elm-spa
```

## available commands

- [elm-spa init](#elm-spa-init) – create a new project
- [elm-spa add](#elm-spa-add) – add a new page
- [elm-spa build](#elm-spa-build) – generate routes and pages


## elm-spa init

```
elm-spa init <directory>

  Create a new elm-spa app in the <directory>
  folder specified.

  examples:
  elm-spa init .
  elm-spa init my-app
```

## elm-spa add

```
elm-spa add <static|sandbox|element|component> <name>

  Create a new page of type <static|sandbox|element|component>
  with the module name <name>.

  examples:
  elm-spa add static Top
  elm-spa add sandbox Posts.Top
  elm-spa add element Posts.Dynamic
  elm-spa add component SignIn
```

## elm-spa build

```
elm-spa build [dir]

  Create "Generated.Route" and "Generated.Pages" modules for
  this project, based on the files in "src/Pages"

  Here are more details on how that works:
  https://www.npmjs.com/package/elm-spa#naming-conventions

  examples:
  elm-spa build
  elm-spa build ../some/other-folder
  elm-spa build ./help
```

## naming conventions

the `elm-spa build` command is pretty useful, because it
automatically generates `Routes.elm` and `Pages.elm` code for you,
based on the naming convention in `src/Pages/*.elm`

Here's an example project structure:

```
src/
└─ Pages/
   ├─ Top.elm
   ├─ About.elm
   ├─ Posts/
   |   ├─ Top.elm
   |   └─ Dynamic.elm
   └─ Authors/
       └─ Dynamic/
           └─ Posts/
               └─ Dynamic.elm
```

When you run `elm-spa build` with these files in the `src/Pages` directory, __elm-spa__ can
automatically generate routes like these:

__Page__ | __Route__ | __Example__
:-- | :-- | :--
`Top.elm` | `/` | -
`About.elm` | `/about` | -
`Posts/Top.elm` | `/posts` | -
`Posts/Dynamic.elm` | `/posts/:param1` | `/posts/123`
`Authors/Dynamic/Posts/Dynamic.elm` | `/authors/:param1/posts/:param2` | `/authors/ryan/posts/123`

### top-level and dynamic routes

- `Top.elm` represents the top-level index in the folder.
- `Dynamic.elm` means that a dynamic parameter should match there.
- `Dynamic` can also be used as a folder, supporting nested dynamic routes.

### accessing url parameters

These dynamic parameters are available as `Flags` for the given page.

Here are some specific examples from the routes above:

```elm
module Pages.About exposing (..)

type alias Flags =
    ()
```

```elm
module Pages.Posts.Dynamic exposing (..)

type alias Flags =
    { param1 : String
    }
```

```elm
module Pages.Authors.Dynamic.Posts.Dynamic exposing (..)

type alias Flags =
    { param1 : String
    , param2 : String
    }
```

These `Flags` are automatically passed in to the `init` function of any `element` or `component` page.


## the elm package

Need more details? Feel free to check out the [official elm package documentation](https://package.elm-lang.org/packages/ryannhg/elm-spa/latest)!


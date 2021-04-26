# Shared state

With __elm-spa__, any time we move from one page to another, the `init` function for that new page is called. This means that the state of the previous page you were looking at has been replaced by the new page's state.

So if we sign in a user on the `SignIn` page, we'll need a place to store the user before navigating over to the `Dashboard`.

This is where the `Shared` module comes in– the perfect place to store data that every page needs to access!

### Ejecting the default file

By default, an empty `Shared.elm` file is generated for us in `.elm-spa/defaults`. When you are ready to share data between pages– move that file from the defaults folder to the `src` folder.

```elm
.elm-spa/
 |- defaults/
     |- Shared.elm

-- move into

src/
 |- Shared.elm
```

Once you've done that, `src/Shared.elm` is under your control– and __elm-spa__ will stop generating the old one. Let's dive into the different parts of that file!

## Shared.Flags

The first thing you'll see is a `Flags` type exposed from the top of the file. If we need to load some initial data from Javascript when our Elm app starts up, we can pass that data in as flags.

When you have the need to send in initial JSON data, take a look at [Elm's official guide on JS interop](https://guide.elm-lang.org/interop/).

## Shared.Model

By default, our `Model` is just an empty record:

```elm
type alias Model =
    {}
```

If we wanted to store a signed-in user, adding it to the model would make it available to all pages:

```elm
type alias Model =
    { user : Maybe User 
    }

type alias User =
    { name : String
    , email : String
    , token : String
    }
```

As we saw in the [pages guide](/guide/03-pages), this `Shared.Model` will be passed into every page– so we can check if `shared.user` has a value or not!

## Shared.init

```elm
init : Flags -> Request -> ( Model, Cmd Msg )
init flags req =
  ...
```

The `init` function is called when your application loads for the first time. It takes in two inputs:

- `Flags` - initial JS values passed in on startup.
- `Request` - the [Request](/guide/request) value with current URL information.

The `init` function returns the initial `Shared.Model`, as well as any side effect's you'd like to run (like initial HTTP requests, etc)

## Shared.Msg

Once you become familiar with [the Elm architecture](https://guide.elm-lang.org/architecture/), you'll recognize the `Msg` type as the only way to update `Shared.Model`.

Maybe it looks something like this for our user example

```elm
type Msg
  = SignedIn User
  | SignedOut
```

These are used in the next section on `Shared.update`!

## Shared.update

```elm
update : Request -> Msg -> Model -> ( Model, Cmd Msg )
```

The `update` function allows you to respond when one of your pages or this module send a `Shared.Msg`. Just like pages, you define a `Msg` type to handle how they update the shared state here.

## Shared.subscriptions

```elm
subscriptions : Request -> Model -> Sub Msg
```

If you want all pages to listen for keyboard events, window resizing, or other external updates, this `subscriptions` function is a great place to wire those up! 

It also has access to the current URL request value, so you can conditionally subscribe to events.

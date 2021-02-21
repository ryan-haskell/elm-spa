# Shared state

With __elm-spa__, every time you navigate from one page to another, the `init` function for that page is called. This means that the `Model` for the page you we're previously looking at has been cleared out. Most of the time, that's a good thing!

Other times, it makes sense to __share state between pages__! Maybe you have a signed-in user, an API token, or settings like "dark mode" that you want to persist from one page to another. This section of the guide will show you how to do that!

## Ejecting the shared file

Default files are automatically generated for you in the `.elm-spa/defaults`, and when you need to tweak them, you can move them into your project's `src` folder. This process is known as "ejecting default files", and comes up for advanced features.

__To get started__ with shared state between pages, move the `.elm-spa/defaults/Shared.elm` file into your `src` folder! After you move that file, `src/Shared.elm` will be the place to make changes!

The rest of this section walks through the different functions in the `Shared` module, so you know what's going on.


### init

```elm
init : Flags -> Request () -> Model -> ( Model, Effect Msg )
```

The `init` function is called when your page loads for the first time. It takes in two inputs:

- `Flags` - initial JSON value passed in from `public/main.js
- `Request ()` - a [Request](/docs/request) value with the current URL information

The `init` function returns the initial `Model`, as well as any `Effect`s you'd like to run (like initial HTTP requests, etc)

__Note:__ The [Effect msg] type is just an alias for `Cmd msg`, but adds support for [elm-program-test]()

### update

```elm
update : Request () -> Msg -> Model -> ( Model, Effect Msg )
```

The `update` function allows you to respond when one of your pages or this module send a `Shared.Msg`. Just like pages, you define `Msg` types and handle how they update the shared state here.

### subscriptions

```elm
subscriptions : Request () -> Model -> Sub Msg
```

If you want all pages to listen for keyboard events, window resizing, or other external updates, this `subscriptions` function is a great place to wire those up! It also has access to the current URL request value, so you can conditionally subscribe to events.

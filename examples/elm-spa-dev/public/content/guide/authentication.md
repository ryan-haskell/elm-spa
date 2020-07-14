# Authentication

User authentication can be handled in many ways! In this example, we'll define custom pages that:

1. Are only visible when a user is logged in
1. Redirect to a sign in page otherwise.
1. Still benefit from elm-spa's route generation!

Let's assume we have a `user : Maybe User` field in the `Shared.Model`, and have a sign-in page at `SignIn.elm`!

## Creating Custom Pages

Because `Spa/Page.elm` is in _your_ project, you can use it to define your own custom page functions.

As long as those functions return the same `Page` type, they are valid! The only downside is that they won't be available for `elm-spa add` command.

If your app involves user authentication, you could make a `protectedSandbox` page type that always gets a `User`, and redirects if one is missing:

```elm
-- within Spa/Page.elm

protectedSandbox :
  { init : User -> Url params -> model
  , update : Msg -> model -> model
  , view : model -> Document msg
  }
  -> Page params (Maybe model) msg
protectedSandbox options =
  { init =
      \shared url ->
        case shared.user of
          Just user ->
            options.init user url |> Tuple.mapFirst Just

          Nothing ->
            ( Nothing
            , Nav.pushUrl url.key (Route.toString Route.SignIn)
            )
  , update = -- ... conditionally call options.update
  , view = -- ... conditionally call options.view
  , subscriptions = \_ -> Sub.none
  , save = \_ shared -> shared
  , load = \_ model -> ( model, Cmd.none )
  }
```

As long as you return a `Page` type, your page will work with the rest of elm-spa's automated routing!

### Usage

```elm
-- (within an actual page)

type alias Model = Maybe SafeModel

page : Page Params Model Msg
page =
  Page.protectedSandbox
    { init = init
    , update = update
    , view = view
    }
```

```elm
init : User -> Url Params -> SafeModel
update : Msg -> SafeModel -> SafeModel
view : SafeModel -> Document Msg
```

One caveat is that the `Model` type exposed by your page is used by the generated code, so your actual model will need a different name (like `SafeModel`).

But now you know that these functions will only be called if the `User` is really logged in!

---

That's it! Swing by the [`#elm-spa-users`](https://elmlang.herokuapp.com/) channel and say hello!
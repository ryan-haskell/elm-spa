# Pages

By default, there are four kinds of pages you can create with __elm-spa__. Always choose the simplest one for the job!

## Static

A simple, static page that just returns a view.

```elm
page : Page Params Model Msg
page =
  Page.static
    { view = view
    }
```

```elm
view : Url Params -> Document Msg
```

## Sandbox

A page that needs to maintain local state.

```elm
page : Page Params Model Msg
page =
  Page.sandbox
    { init = init
    , update = update
    , view = view
    }
```

```elm
init : Url Params -> Model
update : Msg -> Model -> Model
view : Model -> Document Msg
```

## Element

A page that can make side effects with `Cmd` and listen for updates as `Sub`.

```elm
page : Page Params Model Msg
page =
  Page.element
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }
```

```elm
init : Url Params -> ( Model, Cmd Msg )
update : Msg -> Model -> ( Model, Cmd Msg )
view : Model -> Document Msg
subscriptions : Model -> Sub Msg
```

## Application

A page that can read and write to the shared model.

```elm
page : Page Params Model Msg
page =
  Page.application
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    , save = save
    , load = load
    }
```

```elm
init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
update : Msg -> Model -> ( Model, Cmd Msg )
view : Model -> Document Msg
subscriptions : Model -> Sub Msg
save : Model -> Shared.Model -> Shared.Model
load : Shared.Model -> Model -> ( Model, Cmd Msg )
```

### Working with the `Shared.Model`

Because `save` and `load` are both new concepts, here's a quick example of how to use them! Imagine this is your `Shared.Model`:

```elm
-- in Shared.elm
type alias Model =
  { key : Nav.Key
  , url : Url
  , user : Maybe User
  }
```

Let's implement a `SignIn` page together to understand how these functions interact.

#### init

If you're using `Page.application`, your page can tell if the user is already logged in on `init`:

```elm
type alias Model =
  { email : String
  , password : String
  , user : Maybe User
  }

init : Shared.Model -> Url.Params -> ( Model, Cmd Msg )
init shared url =
  ( { email = ""
    , password = ""
    , user = shared.user
    }
  , Cmd.none
  )
```


#### load

On initialization, your page kept a local copy of `user`. This had a tradeoff: the rest of your page functions (`update`, `view`, and `subscriptions`) will be easy to implement and understand, __but__ now it's possible for `shared.user` and your page's `user` to get out of sync.

Imagine the scenario where the navbar had a "Sign out" button. When that button is clicked, the `shared.user` would be signed out, but our page's `Model` would still show the user as logged in! This is where the `load` function comes in!

The `load` function gets called automatically whenever the `Shared.Model` changes. This allows you to respond to external changes to update your local state or send a command!

```elm
load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
  ( { model | user = shared.user }
  , Cmd.none
  )
```

The `load` function lets you explicitly choose which updates from `Shared.Model` you care about, and provides an easy way to keep your `Model` in sync.

#### save

Earlier, when we initialized our page, we kept the `user` in our model. This makes implementing a sign in form easy, without worrying about the `Shared.Model`.

```elm
type Msg
  = UpdatedEmail String
  | UpdatedPassword String
  | AttemptedSignIn
  | GotUser (Maybe User)
  
  
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    UpdatedEmail email ->
      ( { model | email = email }, Cmd.none )

    UpdatedPassword password ->
      ( { model | password = password }, Cmd.none )

    AttemptedSignIn ->
      ( model
      , Api.User.signIn
          { email = model.email
          , password = model.password
          , onResponse = GotUser
          }
      )
      
    GotUser user ->
      ( { model | user = user }
      , Cmd.none
      )
```

The only issue is that the user is only stored on the Sign In page. if we navigate away, we'd lose that data. That's where `save` comes in! 
Anytime your page's `init` or `update` is run, `save` is automatically called (by `src/Main.elm`). This allows you to persist local state to `Shared.Model`.


```elm
save : Model -> Shared.Model -> Shared.Model
save model shared =
  { shared | user = model.user }
```

That's it! Now if we navigate to another page, our user will still be signed in.

---

Let's take a deeper look at [Shared](/guide/shared) together.

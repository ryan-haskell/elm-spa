# User authentication

In a real world application, it's common to have the notion of a signed-in users. When it comes to routing, it's often useful to only allow signed-in users to visit specific pages.

It would be wonderful if we could define logic in _one place_ that guarantees only signed-in users could view those pages:

```elm
case currentVisitor of
     SignedIn user ->
         ProvidePageWith user
  
     NotSignedIn ->
         RedirectTo Route.SignIn
```

__Great news:__ This is exactly what we can do in __elm-spa__!

## Protected pages

At the end of the [pages docs](/docs/pages#pageprotected), we learned that there are also `protected` versions of every __page type__. 

These protected pages have slightly different signatures:

```elm
Page.sandbox :
  { init : Model
  , update : Msg -> Model -> Model
  , view : Model -> View Msg
  }

Page.protected.sandbox :
  { init : User -> Model
  , update : User -> Msg -> Model -> Model
  , view : User -> Model -> View Msg
  }
```

Protected pages are __guaranteed__ to have access to a `User`, so you don't need to handle the impossible case where you are viewing a page without one.

## Following along

Feel free to follow along by creating a new __elm-spa__ project:

```terminal
npm install -g elm-spa@latest
```

```
mkdir user-auth-demo
cd user-auth-demo
elm-spa new
```

This will create a new project that you can run with the `elm-spa server` command!

The complete working example is also available at [examples/03-user-auth](https://github.com/ryannhg/elm-spa/tree/master/examples/03-user-auth) on GitHub.

### Ejecting Auth.elm

There's a default file that has this code stubbed out for you in the `.elm-spa/defaults` folder. Let's eject that file into our `src` folder so we can edit it:

```elm
.elm-spa/
 |- defaults/
     |- Auth.elm

-- move into

src/
 |- Auth.elm
```

Now that we have `Auth.elm` in our `src` folder, we can start adding the code that makes __elm-spa__ protect certain pages.

The `Auth.elm` file only needs to expose two things:
- __User__ - The type that we want to provide all protected pages.
- __beforeProtectedInit__ - The logic that runs before any `Page.protected.*` page loads


```elm
module Auth exposing (User, beforeProtectedInit)

import Gen.Route
import ElmSpa.Internals as ElmSpa
import Request exposing (Request)
import Shared


type alias User =
    ()


beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit shared req =
    ElmSpa.RedirectTo Gen.Route.NotFound
```

By default, this code redirects all protected pages to the `NotFound` page. Instead we want something like this:

```elm
beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit shared req =
    case shared.user of
        Just user ->
            ElmSpa.Provide user

        Nothing ->
            ElmSpa.RedirectTo Gen.Route.SignIn
```

But before that code will work we need to take care of two things:

1. Updating Shared.elm
2. Adding a sign in page

## Updating Shared.elm

If you haven't already ejected `Shared.elm`, you should move it from `.elm-spa/defaults` into your `src` folder. The [shared state](/docs/shared-state) docs cover this file in depth, but we'll provide all the code you'll need to change here.

Let's change `Shared.Model` to keep track of a `Maybe User`, the value that can either be a user or nothing:

```elm
-- src/Shared.elm

type alias Model =
    { user : Maybe User
    }

type alias User =
    { name : String
    }
```

> For now, a user is just going to have a `name` field. This might also store an `email`, `profilePictureUrl`, or `token` too.

Next, we should initially set our user to `Nothing` when our Elm application starts up:

```elm
-- src/Shared.elm

init : Request -> Flags -> ( Model, Cmd Msg )
init _ _ =
    ( { user = Nothing }
    , Cmd.none
    )
```

To make sure that `Auth.elm` is using the same type, __let's expose__ the `User` type from our `Shared` module and reuse it:

```elm
-- src/Shared.elm

module Shared exposing ( ..., User )
```

```elm
-- src/Auth.elm

type alias User =
    Shared.User
```

As the final update to `Shared`, lets add some sign in/sign out logic  

```elm
module Shared exposing ( ..., Msg(..))

import Gen.Route

-- ...

type Msg
    = SignIn User
    | SignOut


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        SignIn user ->
            ( { model | user = Just user }
            , Request.pushRoute Gen.Route.Home_ req
            )
        
        SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            )
```

> Make sure that you expose `Msg(..)` as shown above (instead of just `Msg`). This allows `SignIn` and `SignOut` to be available to pages that send shared updates.

Great work! Let's use that `SignIn` message on a new sign in page.

## Adding a sign in page

With __elm-spa__, adding a new page from the terminal is easy:

```terminal
elm-spa add /sign-in advanced
```

Here we'll start with an "advanced" page, because we'll need to send `Shared.Msg` to sign in and sign out users.

Let's add a few lines of code to `src/Pages/SignIn.elm`:

```elm
-- Import some HTML

import Html exposing (..)
import Html.Events as Events
```

```elm
-- Replace Msg with this

type Msg = ClickedSignIn
```

```elm
-- Replace update with this

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedSignIn ->
            ( model
            , Effect.fromShared (Shared.SignIn "Ryan")
            )
```

```elm
-- Make view show a sign out button

view : Model -> Html msg
view model =
    { title = "Sign In"
    , body =
          [ button
              [ Events.onClick ClickedSignIn ]
              [ text "Sign in" ]
          ]
```

Nice work- we're only a step away from getting auth set up!

### Final touches to Auth.elm

Now that we have a `shared.user` and a `SignIn` route, let's bring it all together in the `Auth.elm` file

```elm
-- src/Auth.elm

beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit shared req =
    case shared.user of
        Just user ->
            ElmSpa.Provide user

        Nothing ->
            ElmSpa.RedirectTo Gen.Route.SignIn
```

Now visiting [http://localhost:1234/sign-in](http://localhost:1234/sign-in) will show us our sign in page, complete with a sign in button!

Clicking the "Sign in" button signs in the user when clicked. Because of the logic we added in `Shared.elm`, this also redirects the user to the homepage after sign in!

## Protecting our homepage

Let's make it so the homepage is only available to signed in users. 

Let's create a fresh homepage with the __elm-spa add__:

```terminal
elm-spa add / advanced
```

Now that `Auth.elm` is set up, we only need to change this one line to guarantee only signed-in users can see the homepage:

```elm
-- src/Pages/Home_.elm


Page.advanced

-- this becomes

Page.protected.advanced
```

This means our `init`, `update`, `view`, and `subscribe` now have access to a `User`

```elm
-- src/Pages/Home_.elm

import Auth exposing (User)

-- ...

init : User -> ( Model, Effect Msg )
init user =
    ...

update : User -> Msg -> Model -> ( Model, Effect Msg )
update user msg model =
    ...

view : User -> Model -> View Msg
view user model =
    ...

subscriptions : User -> Model -> Sub Msg
subscriptions user model =
    ...
```

If you don't want to pass a `User` into any of these functions, you can skip the user argument in your `page` function, using an inline function or the `always` function

```elm
-- Only the view is passed User

page shared req =
    Page.protected.advanced
        { init = \_ -> init
        , update = \_ -> update
        , view = view
        , subscriptions = \_ -> subscriptions
        }
```

> I recommend this second approach, because it doesn't affect any of our other functions!


Let's use that `user` so the homepage greets them by name:

```elm
-- src/Pages/Home_.elm

import Html exposing (..)
import Html.Events as Events

-- ...

view : User -> Model -> View Msg
view user model =
    { title = "Homepage"
    , body = 
          [ h1 [] [ text ("Hello, " ++ user.name ++ "!") ]
          ]
    }
```

#### Try it out!

Now if we visit [http://localhost:1234](http://localhost:1234), we will immediately be redirected to `/sign-in`, because we haven't signed in yet!

Clicking the "Sign in" button takes us back to the homepage, and we should see "Hello, Ryan!" printed on the screen.


### The cherry on top

Let's wrap things up by wiring up a "Sign out" button to the homepage:

```elm
-- src/Pages/Home_.elm

type Msg = ClickedSignOut

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedSignOut ->
            ( model
            , Effect.fromShared Shared.SignOut
            )

-- ...

view : User -> Model -> View Msg
view user model =
    { title = "Homepage"
    , body = 
          [ h1 [] [ text ("Hello, " ++ user.name ++ "!") ]
          , button
                [ Events.onClick ClickedSignOut ]
                [ text "Sign out" ]
          ]
    }
```

Now everything is working! Visiting the `/sign-in` page and clicking "Sign In" signs in the user and redirects to the homepage. Clicking "Sign out" on the homepage signs out the user, and our `Auth.elm` logic automatically redirects to the `SignIn` page.


#### But wait...

When we refresh the page, the user is signed out... how can we keep them signed in after refresh? Sounds like a job for [local storage](/guides/local-storage)!

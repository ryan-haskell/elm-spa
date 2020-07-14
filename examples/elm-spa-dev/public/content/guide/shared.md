# Shared

Whether you're sharing layouts or information between pages, the `Shared` module is the place to be!

## Flags

If you have initial data you want to pass into your Elm application, you should provide it via `Flags`.

When you create a project with `elm-spa init`, a file will be created at `public/main.js`:

```javascript
// (in public/main.js)
var flags = null
var app = Elm.Main.init({ flags: flags })
```

The value passed into the `flags` needs to match up with the type of `Shared.Flags`, for it to be passed into `Shared.init`.

Here's an example:

```javascript
// (in public/main.js)
var flags = { project: "elm-spa", year: 2020 }
```

```elm
-- (in src/Shared.elm)
type alias Flags =
    { project : String
    , year : Int
    }
```

Once you get comfortable with flags, I recommend always using `Json.Value` from the [elm/json](https://package.elm-lang.org/packages/elm/json/latest) package as your Flags:

```elm
import Json.Decode as Json

type alias Flags =
    Json.Value

type alias InitialData =
  { project : String
  , year : Int
  }

decoder : Json.Decoder InitialData
decoder =
    Json.map2 InitialData
        (Json.field "project" Json.string)
        (Json.field "year" Json.int)

init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    case Json.decodeValue decoder flags of
        Ok initialData -> -- Initialize app
        Err reason ->     -- Handle failure
```

This way, you can create a decoder to gracefully handle the JSON being sent into your Elm application.

Learn more about [Flags](https://guide.elm-lang.org/interop/flags.html) in the official Elm guide.

## Model

All data in `Shared.Model` will persist across page navigation.

By default, it only contains `key` and `url`, which are required for the programmatic navigation and reading URL information in your application. 

This makes it a great choice for things like logged-in users, dark-mode, or any other data displayed on shared components needed by navbars or footers.

```elm
type alias Model =
  { key : Key
  , url : Url
  , user : Maybe User
  }
```

Here we added a `user` field that we can update with the next function!

## update

The `Shared.update` function is just like a normal `update` function in Elm. It takes in messages and returns the latest version of the `Model`. In this case, the `Model` is the `Shared.Model` mentioned above.

```elm
type Msg
    = SignIn User
    | SignOut

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SignIn user ->
            ( { model | user = Just user }
            , Cmd.none
            )

        SignOut ->
            ( { model | user = Nothing }
            , Cmd.none
            )
```

This is just an example of using `update` with the `user` field we added earlier. Let's call those messages from our view.

## view

The `Shared.view` function is a great place to render things that should persist across page transitions. It comes with more than just a `Model`, so you can insert the `page` wherever you'd like:

```elm
import Components.Navbar as Navbar
import Components.Footer as Footer


view :
  { page : Document msg
  , toMsg : Msg -> msg
  }
  -> Model
  -> Document msg
view { page, toMsg } model =
    { title = page.title
    , body =
        [ Navbar.view
            { user = model.user
            , onSignIn = toMsg SignIn
            , onSignOut = toMsg SignOut
            }
        , div [ class "page" ] page.body
        , Footer.view
        ]
    }
```

Using the `toMsg` function passed in the first argument, we're able to convert `Shared.Msg` to the same `msg` that our `view` function returns.

If you want components to send `Shared.Msg`, make sure to use that function first!

---

Let's take a look at [Components](/guide/components) now!
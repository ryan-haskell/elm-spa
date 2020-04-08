# from scratch
> a guide on how to use elm-spa without the cli

## getting setup

1. Install [elm](https://guide.elm-lang.org/install/elm.html)

1. Optional: Install [VS Code](https://code.visualstudio.com/download) and the [elm extension](https://marketplace.visualstudio.com/items?itemName=Elmtooling.elm-ls-vscode)

## creating a new project

Create a new Elm project using the `elm init` command:

```terminal
elm init
```

This will create an `elm.json` file and a `src` folder. Let's install two more packages for our project:

```
elm install elm/url
elm install ryannhg/elm-spa
```

## src/Main.elm

First, we create a new file called `src/Main.elm`- which is the entrypoint for our new Elm application. Let's build it together: 

### imports and main

We need to create a `main` function for Elm to call
when our application starts up. `Browser.application` supports
client-side routing, so that's the function we'll want to
call for our single page application.

```elm
module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Document exposing (Document)
import Global
import Pages
import Url exposing (Url)


main : Program Global.Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = LinkChanged
        , onUrlChange = UrlChanged
        }
```

The `Document`, `Global`, and `Pages` modules haven't been created yet, but `Browser`, `Browser.Navigation`, and `Url` come from the `elm/browser` and `elm/url` packages.


### model and init

Here we'll store four things:

1. The current URL

1. A unique key used for navigation

1. The global state of our app

1. The state of the page we are currently viewing

```elm
type alias Model =
    { url : Url
    , key : Nav.Key
    , global : Global.Model
    , page : Pages.Model
    }
```

We'll implement `Global.Model` and `Pages.Model` soon,
but for now let's continue by implementing the `init`
function.

```elm
init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( globalModel, globalCmd ) =
            Global.init flags url key

        ( pageModel, pageCmd, pageGlobalCmd ) =
            Pages.init url globalModel
    in
    ( Model url key globalModel pagesModel
    , Cmd.batch
        [ Cmd.map FromGlobal globalCmd
        , Cmd.map FromGlobal pageGlobalCmd
        , Cmd.map FromPage pageCmd
        ]
    )
```

Here we assume `Global.init` handles the initialization of the global state between pages, and can send a global command like an HTTP request or another side effect.

Similarly, `Pages.init` initializes the current page based on the current URL and the initialize global state. In addition to returning `Cmd Pages.Msg`, pages can also return `Cmd Global.Msg`. This allows them to affect the global state shared between pages.

We'll implement those functions together later!

### msg and update

```elm
type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | FromGlobal Global.Msg
    | FromPage Page.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( model
            , Nav.pushUrl model.key (Url.toString url)
            )

        LinkClicked (Browser.External href) ->
            ( model
            , Nav.load href
            )

        UrlChanged url ->
            let
                ( pageModel, pageCmd, pageGlobalCmd ) =
                    Pages.init url model.global
            in
            ( { model | url = url, page = pageModel }
            , Cmd.batch
                [ Cmd.map FromGlobal pageGlobalCmd
                , Cmd.map FromPage pageCmd
                ]
            )

        FromGlobal globalMsg ->
            let
                ( globalModel, globalCmd ) =
                    Global.update globalMsg model.global
            in
            ( { model | global = globalModel }
            , Cmd.map FromGlobal globalCmd
            )

        FromPages pageMsg ->
            let
                ( pageModel, pageCmd, pageGlobalCmd ) =
                    Pages.update pageMsg model.page model.global
            in
            ( { model | page = pageModel }
            , Cmd.batch
                [ Cmd.map FromGlobal pageGlobalCmd
                , Cmd.map FromPage pageCmd
                ]
            )
```

Here we define and handle the four messages we might receive from the user:

1. They click a link, either internal or external, and we navigate to the correct page.

1. The URL changes and we need to initialize the new page.

1. We received an update for the global state between pages.

1. We received an update for a page.


### view + subscriptions

The view and subscriptions for the page are based on the current `Model` of the application:

```elm
view : Model -> Document Msg
view model =
    Global.view
        { global = model.global
        , fromGlobal = FromGlobal
        , page = Document.map FromPage (Pages.view model.page model.global)
        }
```

The `view` function calls the global layout, and provides three things:

1. The current global state of the application.
1. A way to upgrade a `Global.Msg` into a `Msg`.
1. The page's view, so it can decide where to render the page.

#### why those three values?

The pages within our app will return `Document Page.Msg`.

But we want components in our global view to be able to send global messages (`Global.Msg`).

In Elm, our function cannot return both `Document Page.Msg` and `Document Global.Msg`. To make sure our view function returns the same type:

1. We call `Document.map FromPage` to convert `Document Pages.Msg` into `Document Msg`
1. We provide `fromGlobal` to `Global.view`, so it can convert `Global.Msg` values into `Msg` values!

Now we are returning `Document Msg` to `Main.view`, and we can handle messages from different sources. Later, we'll see `Global.view`- which will have a more concrete example for how to use those three values.

For now, let's wrap up by handling subscriptions!

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map FromGlobal (Global.subscriptions model.global)
        , Sub.map FromPage (Pages.subscriptions model.page model.global)
        ]
```

Finally, we subscribe to events from the global and page modules, in case we want to track things like window resize or keyboard events.

That's it! The source code for src/Main.elm file is available [here](#todo).

## src/Document.elm

Before we get into `Global` and `Pages`, let's define the `Document` module, which defines what our pages should be returning:

```elm
module Document exposing (Document, map)

import Html exposing (Html)


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


map : (msg1 -> msg2) -> Document msg1 -> Document msg2
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }
```

That's all we need for this file! We just redefined `Browser.Document` and created a `map` function a way to go from one `Document` to another. The `map` function is the one we used above in `src/Main.elm`.


## src/Global.elm

The `Global` module initializes, updates, views, and handles subscriptions for the state we want to share across pages.

For example, if a user logs in, we don't want navigating from page to page to log them back out! 

For that reason, it's nice to have a `Global.Model` for our application.

```elm
module Global exposing
    ( Flags
    , Model
    , Msg
    , init
    , update
    , view
    , subscriptions
    -- commands
    , increment
    , navigateTo
    )

import Browser.Navigation as Nav
import Document exposing (Document)
import Html exposing (Html)
import Html.Attributes exposing (class)
import Url exposing (Url)
import Route exposing (Route)
import Task
```

### flags, model, and init

```elm
type alias Flags =
    ()


type alias Model =
    { key : Nav.Key
    , counter : Int
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ key =
    ( Model key 0
    , Cmd.none
    )
```

The `Flags` type is the data we pass in from JavaScript when starting our Elm application. Here we are using an empty tuple `()` to say that we won't be taking in any data from JS.

The `Global.Model` needs to store `Nav.Key` so it can navigate between pages. For that reason, we ignore the flags and url, but store `key` to our model.

For this example application, we're also storing a global `counter` value. Later, we'll demonstrate how to change that global counter from both pages and global components!


### msg and update

```elm
type Msg
    = NavigatedTo Route
    | Increment


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigatedTo route ->
            ( model
            , Nav.pushUrl model.key (Route.toHref route)
            )
        
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )
```

Here we handle `NavigatedTo`, a message that comes with a `Route`. A `Route` is just a custom type that holds all the URLs our application accepts. We'll define the `Route` module after this one!

When we get the `NavigatedTo` message from our application, we use the `Route.toHref` function to convert our route to a `String`. Then we can call `Nav.pushUrl` to change the URL for our app.

We also include an implementation for `Increment`. We'll see an example of changing global state soon.

#### global commands

To allow pages to send `Cmd Global.Msg`, we need to expose the commands we want our users to call.

Here we'll define a helper function called `send` that turns a `Global.Msg` into a `Cmd Global.Msg`:

```elm
send : Msg -> Cmd Msg
send msg =
    Task.succeed msg |> Task.perform identity
```

From there, we can expose commands easily:

```elm
navigateTo : Route -> Cmd Msg
navigateTo route =
    send (NavigatedTo route)
```

```elm
increment : Cmd Msg
increment =
    send Increment
```


### view + subscriptions

Our view function received the three pieces of information we passed in from `Main.view`.

```elm
view :
    { global : Model
    , toMsg : Msg -> msg
    , page : Document msg
    }
    -> Document msg
view { global, toMsg, page } =
    { title = page.title
    , body =
        [ Html.div [ class "layout" ]
            [ navbar
                { increment = toMsg Increment
                , counter = global.counter
                }
            , Html.div [ class "page" ] page.body
            , footer
            ]
        ]
    }


navbar :
    { increment : msg
    , counter : Int
    }
    -> Html msg
navbar options =
    Html.header [ class "navbar" ]
        [ Html.text (String.fromInt options.counter)
        , Html.button
            [ Events.onClick options.increment ]
            [ Html.text "+" ]
        ]


footer : Html msg
footer =
    Html.footer [ class "footer" ] [ text "built with elm!" ]
```

The `view` function has access to the current `global` model, `page`, and shared components can even send messages with the help of `toMsg`.

The `page` document's title is used by our view.

By passing in the `page` value, our layout can decide where to render the
page view. Here we render it in between two components: navbar and footer

Our `navbar` is able to access the current `counter` value and can send the `increment` message when the button is clicked.

Here we use `toMsg` to make sure that the return type is `Html msg` instead of `Html Msg`. Using `toMsg` allows us to put the navbar alongside the `page.body` and `footer`- because they all return `Html msg`!

```elm
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
```

Our application doesn't require any subscriptions, but you could add them in here if you need them later!

That's `src/Global.elm`. The complete source code is [available here](#todo).


## src/Route.elm

Earlier in our `Global` module, we used `Route` to handle page navigation messages. Let's define a `Route` module for this application, so we can see how it works.

```elm
module Route exposing (Route(..), fromUrl, toHref)

import Url exposing (Url)
import Url.Parser exposing (Parser, (</>), string, s)
```

Our route module will be using a `Url.Parser` from the `elm/url` package to implement `fromUrl`.

### Route

```elm
type Route
    = Top
    | AboutUs
    | Posts
    | Post String
    | NotFound
```

When we define this `Route` type, we're saying that these are the only five pages a user can ever be on while using our application.

### fromUrl

We can create our `Route` by parsing a `Url`.

```elm
fromUrl : Url -> Route
fromUrl url =
    [ Parser.map Top Parser.top
    , Parser.map AboutUs (Parser.s "about-us")
    , Parser.map Posts (Parser.s "posts")
    , Parser.map Post (Parser.s "posts" </> Parser.string)
    ]
        |> Parser.oneOf
        |> Parser.run url
        |> Maybe.withDefault NotFound
```

Here we try to find a route match. If we can't find one, we default to `NotFound`. That way we always have a `Route` no matter what `Url` we are given.

### toHref

If we want to turn our `AboutUs` route back into `/about-us`, we'll need to define a function to do that for us:

```elm
toHref : Route -> String
toHref route =
    case route of
        Top ->
            "/"

        AboutUs ->
            "/about-us"
        
        Posts ->
            "/posts"
        
        Post id ->
            "/posts/" ++ id
        
        NotFound ->
            "/not-found"
```

This function allows all our URLs to be handled in one place in the application.

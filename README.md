# ryannhg/elm-app
> a way to build single page apps with Elm.

__Note:__ This package is still under design/development. (but one day, it may become an actual package!)


## try it out

```
git clone https://github.com/ryannhg/elm-app
cd elm-app/examples/basic
npm install
npm run dev
```

Mess around with the files in `examples/basic/src` and change things!


## overview for readme scrollers

this package is a wrapper around Elm's `Browser.application`, adding in page transitions and utilities for adding in new pages and routes.

here's what it looks like to use it:


### src/Main.elm
> Uses `Application.create`

This is the entrypoint to the app, it imports a few things:

- `Application` - (this package)
- `App` - the top level `Model`, `Msg`, `init`, `update`, `subscriptions`, and `view`
- `Context` - the shared state between pages.
- `Route` - the routes for your application
- `Flags` - the initial JSON sent into the app


```elm
module Main exposing (main)

import App
import Application exposing (Application)
import Context
import Flags exposing (Flags)
import Route exposing (Route)


main : Application Flags Context.Model Context.Msg App.Model App.Msg
main =
    Application.create
        { transition = 200
        , context =
            { init = Context.init
            , update = Context.update
            , view = Context.view
            , subscriptions = Context.subscriptions
            }
        , page =
            { init = App.init
            , update = App.update
            , bundle = App.bundle
            }
        , route =
            { fromUrl = Route.fromUrl
            , toPath = Route.toPath
            }
        }
```


### src/Pages/Homepage.elm
> uses `Application.Page.static`

The homepage is just a static page, so it's just a `view` and a `title` for the browser tab:

```elm
module Pages.Homepage exposing
    ( title
    , view
    )

import Html exposing (..)


title : String
title =
    "Homepage"


view : Html Never
view =
    div []
        [ h1 [] [ text "Homepage!" ]
        , p [] [ text "It's boring, but it works!" ]
        ]

```


### src/Pages/Counter.elm
> uses `Application.Page.Sandbox`

The counter page doesn't has a `Model` to maintain, so it needs an `init` and an `update`:

```elm
module Pages.Counter exposing
    ( Model
    , Msg
    , init
    , title
    , update
    , view
    )

import Html exposing (..)
import Html.Events as Events


type alias Model =
    { counter : Int
    }


type Msg
    = Increment
    | Decrement


title : Model -> String
title model =
    "Counter: " ++ String.fromInt model.counter ++ " | elm-app"


init : Model
init =
    { counter = 0
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Decrement ->
            { model | counter = model.counter - 1 }

        Increment ->
            { model | counter = model.counter + 1 }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Counter!" ]
        , p [] [ text "Even the browser tab updates!" ]
        , div []
            [ button [ Events.onClick Decrement ] [ text "-" ]
            , text (String.fromInt model.counter)
            , button [ Events.onClick Increment ] [ text "+" ]
            ]
        ]

```

### src/App.elm

There's one file where you wire these pages up, and the `Application.Page` module has a bunch of helpers for dealing with pages of different shapes and complexities.

(In theory, this file could be generated, but typing it isn't too hard either!)

```elm
module App exposing
    ( Model
    , Msg
    , bundle
    , init
    , update
    )

import Application.Page as Page exposing (Context)
import Browser
import Context
import Flags exposing (Flags)
import Html exposing (Html)
import Pages.Counter
import Pages.Homepage
import Pages.NotFound
import Route exposing (Route)


type Model
    = HomepageModel ()
    | CounterModel Pages.Counter.Model
    | NotFoundModel ()


type Msg
    = HomepageMsg Never
    | CounterMsg Pages.Counter.Msg
    | NotFoundMsg Never


pages =
    { homepage =
        Page.static
            { title = Pages.Homepage.title
            , view = Pages.Homepage.view
            , toModel = HomepageModel
            }
    , counter =
        Page.sandbox
            { title = Pages.Counter.title
            , init = Pages.Counter.init
            , update = Pages.Counter.update
            , view = Pages.Counter.view
            , toModel = CounterModel
            , toMsg = CounterMsg
            }
    , notFound =
        Page.static
            { title = Pages.NotFound.title
            , view = Pages.NotFound.view
            , toModel = NotFoundModel
            }
    }


init :
    Context Flags Route Context.Model
    -> ( Model, Cmd Msg, Cmd Context.Msg )
init context =
    case context.route of
        Route.Homepage ->
            Page.init
                { page = pages.homepage
                , context = context
                }

        Route.Counter ->
            Page.init
                { page = pages.counter
                , context = context
                }

        Route.NotFound ->
            Page.init
                { page = pages.notFound
                , context = context
                }


update :
    Context Flags Route Context.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd Context.Msg )
update context appMsg appModel =
    case ( appModel, appMsg ) of
        ( HomepageModel model, HomepageMsg msg ) ->
            Page.update
                { page = pages.homepage
                , msg = msg
                , model = model
                , context = context
                }

        ( HomepageModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( CounterModel model, CounterMsg msg ) ->
            Page.update
                { page = pages.counter
                , msg = msg
                , model = model
                , context = context
                }

        ( CounterModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( NotFoundModel model, NotFoundMsg msg ) ->
            Page.update
                { page = pages.notFound
                , msg = msg
                , model = model
                , context = context
                }

        ( NotFoundModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )


bundle :
    Context Flags Route Context.Model
    -> Model
    -> Page.Bundle Msg
bundle context appModel =
    case appModel of
        HomepageModel model ->
            Page.bundle
                { page = pages.homepage
                , model = model
                , context = context
                }

        CounterModel model ->
            Page.bundle
                { page = pages.counter
                , model = model
                , context = context
                }

        NotFoundModel model ->
            Page.bundle
                { page = pages.notFound
                , model = model
                , context = context
                }
```

### src/Context.elm

This is the "component" that wraps your whole single page app.

It's `update` function has access to `navigateTo`, allowing page navigation.

The `view` function also has access to your page, so you can insert it where you like in the layout!

```elm
module Context exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Application
import Data.User exposing (User)
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Html.Events as Events
import Route exposing (Route)
import Utils.Cmd


type alias Model =
    { user : Maybe User
    }


type Msg
    = SignIn (Result String User)
    | SignOut


init : Route -> Flags -> ( Model, Cmd Msg )
init route flags =
    ( { user = Nothing }
    , Cmd.none
    )


update :
    Application.Messages Route msg
    -> Route
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd msg )
update { navigateTo } route msg model =
    case msg of
        SignIn (Ok user) ->
            ( { model | user = Just user }
            , Cmd.none
            , navigateTo Route.Homepage
            )

        SignIn (Err _) ->
            Utils.Cmd.pure model

        SignOut ->
            Utils.Cmd.pure { model | user = Nothing }


view :
    { route : Route
    , context : Model
    , toMsg : Msg -> msg
    , viewPage : Html msg
    }
    -> Html msg
view { context, route, toMsg, viewPage } =
    div [ class "layout" ]
        [ Html.map toMsg (viewNavbar route context)
        , div [ class "container" ] [ viewPage ]
        , Html.map toMsg (viewFooter context)
        ]


viewNavbar : Route -> Model -> Html Msg
viewNavbar currentRoute model =
    header [ class "navbar" ]
        [ div [ class "navbar__links" ]
            (List.map
                (viewLink currentRoute)
                [ Route.Homepage, Route.Counter, Route.Random ]
            )
        , case model.user of
            Just _ ->
                button [ Events.onClick SignOut ] [ text <| "Sign out" ]

            Nothing ->
                a [ Attr.href "/sign-in" ] [ text "Sign in" ]
        ]


viewLink : Route -> Route -> Html msg
viewLink currentRoute route =
    a
        [ class "navbar__link-item"
        , Attr.href (Route.toPath route)
        , Attr.style "font-weight"
            (if route == currentRoute then
                "bold"

             else
                "normal"
            )
        ]
        [ text (linkLabel route) ]


linkLabel : Route -> String
linkLabel route =
    case route of
        Route.Homepage ->
            "Home"

        Route.Counter ->
            "Counter"

        Route.SignIn ->
            "Sign In"

        Route.Random ->
            "Random"

        Route.NotFound ->
            "Not found"


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ Attr.class "footer" ]
        [ model.user
            |> Maybe.map Data.User.username
            |> Maybe.withDefault "not signed in"
            |> (++) "Current user: "
            |> text
        ]


subscriptions : Route -> Model -> Sub Msg
subscriptions route model =
    Sub.none
```

## Still reading?

Oh wow. Maybe you should just check out the [basic example](./examples/basic) included in the repo.

Just clone, `npm install` and `npm run dev` for a hot-reloading magical environment.

Add a page or something- and let me know how it goes!

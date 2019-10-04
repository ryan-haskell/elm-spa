# ryannhg/elm-app
> a way to build single page apps with Elm.

## try it out

```
elm install ryannhg/elm-app
```

## quick overview

this package is a wrapper around Elm's `Browser.application`, adding in page transitions and utilities for adding in new pages and routes.

here's what it looks like to use it:


### src/Main.elm

This is the entrypoint to the app, it imports:

- `Application` - this package
- `App` - the top level `Model`, `Msg`, `init`, `update`, `subscriptions`, and `view`
- `

```elm
module Main exposing (main)

import Application exposing (Application)

import App
import Context
import Route
import Flags exposing (Flags)


main : Application Flags Context.Model Context.Msg App.Model App.Msg
main =
  Application.create
    { transition = 300
    , toRoute = Route.fromUrl
    , title = Route.title
    , context =
        { init = Context.init
        , update = Context.update
        , view = Context.view
        , subscriptions = Context.subscriptions
        }
    , page =
        { init = App.init
        , update = App.update
        , view = App.view
        , subscriptions = App.subscriptions
        }
    }
```


### src/Pages/Homepage.elm
> Uses `Application.Page.static`

The homepage is static, so it's just a `view`:

```elm
module Pages.Homepage exposing (view)

import Html exposing (Html)


view : Html Never
view =
  Html.text "Homepage!"
```


### src/Pages/Counter.elm
> Uses `Application.Page.Sandbox`

The counter page doesn't have any side effects:

```elm
module Pages.Counter exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Events as Events


type alias Model =
  { counter : Int
  }


type Msg
  = Increment
  | Decrement


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
    [ button [ Events.onClick Decrement ] [ text "-" ]
    , text (String.fromInt model.counter)
    , button [ Events.onClick Increment ] [ text "+" ]
    ]
```


### src/Pages/Random.elm
> Uses `Application.Page.element`

The random page doesn't need to update the context of the application:

```elm
module Pages.Random exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Flags exposing (Flags)
import Html exposing (..)
import Html.Events as Events
import Random


type alias Model =
    { roll : Maybe Int
    }

type Msg
    = Roll
    | GotOutcome Int


init : Flags -> ( Model, Cmd Msg )
init _ =
  ( { roll = Nothing }
  , Cmd.none
  )

rollDice : Model -> ( Model, Cmd Msg )
rollDice model =
  ( model
  , Random.generate GotOutcome (Random.int 1 6)
  )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Roll ->
      rollDice model

    GotOutcome value ->
      ( { model | roll = Just value }
      , Cmd.none
      )

view : Model -> Html Msg
view model =
  div []
    [ button [ Events.onClick Roll ] [ text "Roll" ]
    , p []
        [ case model.roll of
            Just roll ->
              text (String.fromInt roll)
            Nothing ->
              text "Click the button!"
        ]
    ]

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
```
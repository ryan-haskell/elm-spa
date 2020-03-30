# examples/transition

```
npm start
```

## how i added transitions

```
npm install -g elm-spa
elm-spa init transitions
cd transitions
npm start
```

### 1. add more info to the model

__`src/Main.elm`__

```elm
type alias Model =
    { key : Key
    , url : Url
    , isTransitioning : Bool
    , global : Global.Model
    , page : Pages.Model
    }
```

### 2. handle updates to that state

Added a new message called `PageLoaded` msg to delay the effects of `UrlChanged`:

__`src/Main.elm`__

```elm
type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | PageLoaded Url
    | Global Global.Msg
    | Page Pages.Msg
```

```elm
import Process
import Task

delay : Float -> msg -> Cmd msg
delay ms msg =
    Process.sleep ms
        |> Task.andThen (\_ -> Task.succeed msg)
        |> Task.perform identity
```

```elm
update msg model =
    case msg of

        -- ...

        UrlChanged url ->
            ( { model | isTransitioning = True }
            , delay 300 (PageLoaded url)
            )

        PageLoaded url ->
            let
                ( page, pageCmd, globalCmd ) =
                    Pages.init (fromUrl url) model.global
            in
            ( { model
                | isTransitioning = False
                , url = url
                , page = page
              }
            , Cmd.batch
                [ Cmd.map Page pageCmd
                , Cmd.map Global globalCmd
                ]
            )
```

### 3. pass that info to the layout component

__`src/Main.elm`__

```elm
Global.view
    { page = Pages.view model.page model.global |> documentMap Page
    , global = model.global
    , toMsg = Global
    , isTransitioning = model.isTransitioning
    }
```

__`src/Global.elm`__

```elm
view :
    { page : Document msg
    , global : Model
    , toMsg : Msg -> msg
    , isTransitioning : Bool
    }
    -> Document msg
view { page, global, toMsg, isTransitioning } =
    Components.layout
        { page = page
        , isTransitioning = isTransitioning
        }
```

__`src/Components.elm`__

```elm
layout :
    { page : Document msg
    , isTransitioning : Bool
    }
    -> Document msg
layout { page, isTransitioning } =
    { title = page.title
    , body =
        [ div [ class "column spacing--large pad--medium container h--fill" ]
            [ navbar
            , div
                [ class "column"
                , style "flex" "1 0 auto"
                , style "transition" "opacity 300ms ease-in-out"
                , style "opacity"
                    (if isTransitioning then
                        "0"

                     else
                        "1"
                    )
                ]
                page.body
            , footer
            ]
        ]
    }
```

### works with elm-ui too!

this example is using `elm/html`, but a similar strategy would work for `elm-ui` (just use `alpha` instead!)
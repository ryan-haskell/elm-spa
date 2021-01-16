# Views

With __elm-spa__, you can choose any Elm view library you like. Whether it's 
[elm/html](#), [Elm UI](#), or even your own custom library, the `View` module 
has got you covered!

```elm
type alias View msg =
    { title : String
    , body : List (Html msg)
    }
```

By default, a `View` lets you set the tab title as well as render some `Html` in
the `body` value.
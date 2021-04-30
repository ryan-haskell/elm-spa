# Views

With __elm-spa__, you can choose any Elm view library you like. Whether it's [elm/html](https://package.elm-lang.org/packages/elm/html/latest/), [Elm UI](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/), or even your own custom library, the `View` module has you covered!

### Ejecting the default view

If you would like to switch to another UI library– you can move the `View.elm` file from `.elm-spa/defaults` into your `src` folder:

```elm
.elm-spa/
 |- defaults/
     |- View.elm

-- move into

src/
 |- View.elm
```

From here on out, __elm-spa__ will use your `View` module as the return type for all `view` functions across your pages!

## View msg

By default, a `View` lets you set the tab title as well as render some `Html` in the `body` value.

```elm
type alias View msg =
    { title : String
    , body : List (Html msg)
    }
```

### Using Elm UI

If you wanted to use Elm UI, a popular HTML/CSS alternative in the community, you would tweak this `View msg` type to not use `Html msg`:

```elm
import Element exposing (Element)

type alias View msg =
    { title : String
    , element : Element msg
    }
```


## View.toBrowserDocument

Whichever library you use, Elm needs a way to convert it to a `Browser.Document` type. Make sure to provide this function, so __elm-spa__ can convert your UI at the top level.

Here's an example for Elm UI:

```elm
toBrowserDocument : View msg -> Browser.Document msg
toBrowserDocument view =
    { title = view.title
    , body =
        [ Element.layout [] view.element
        ]
    }
```

## View.map

When connecting pages together, __elm-spa__ needs a way to map from one `View msg` to another. For `elm/html`, this is the `Html.map` function.

But when using a different library, you'll need to specify the `map` function for things to work.

Fortunately, most UI libraries ship with their own! Here's another example with Elm UI:

```elm
map : (a -> b) -> View a -> View b
map fn view =
    { title = view.title
    , element = Element.map fn view.element
    }
```

## View.none

When loading between pages, __elm-spa__ also needs a `View.none` to be specified for your custom `View` type.

For Elm UI, that is just `Element.none`:

```elm
none : View msg
none =
    { title = ""
    , element = Element.none
    }
```

## View.placeholder

The last thing you need to provide is a `View.placeholder`, used by the __elm-spa add__ command to provide a stubbed out `view` function implementation.

Here's an example of a `placeholder` with Elm UI:

```elm
placeholder : String -> View msg
placeholder pageName =
    { title = pageName
    , element = Element.text pageName
    }
```

---

__Next up:__ [Examples](../examples)

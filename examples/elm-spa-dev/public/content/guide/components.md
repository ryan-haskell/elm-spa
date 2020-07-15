# Components

In Elm, components don't have to be complicated! In fact, most of the time, you can use boring functions:

```elm
module Components.Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)


view : Html msg
view =
  footer [ class "footer" ] [ text "built with elm-spa" ]
```

## Passing in data

If you have data you need to display in a component, you can pass them in as arguments:

```elm
module Components.Navbar exposing (view)

import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Spa.Generated.Route as Route


view : { user : Maybe User } -> Html msg
view options =
  header [ class "navbar" ]
      [ a [ href Route.Top ] [ text "Home" ]
      , a [ href Route.NotFound ] [ text "Not found" ]
      , case options.user of
          Just user -> button [] [ text "Sign out" ]
          Nothing -> button [] [ text "Sign in" ]
      ]


href : Route -> Html.Attribute msg
href route =
  Attr.href (Route.toString route)
```

## Handling messages

What's the easiest way to make a component reusable? Pass in the messages it sends! Rather than giving it it's own hardcoded `Msg` type, pass in the `msg` as an argument. 

This enables the caller to decide how to handle events from components, and makes it easier to test component functions without needing to mock the entire application.

```elm
import Html.Events as Events

view :
  { user : Maybe User
  , onSignIn : msg
  , onSignOut : msg
  }
  -> Html msg
view options =
  header [ class "navbar" ]
      [ a [ href Route.Top ] [ text "Home" ]
      , a [ href Route.NotFound ] [ text "Not found" ]
      , case options.user of
          Just _ ->
            button [ Events.onClick options.onSignOut ]
                [ text "Sign out" ]
          Nothing ->
            button [ Events.onClick options.onSignIn ]
                [ text "Sign in" ]
      ]
```

## Fancy Components

In JavaScript frameworks like React or Vue.js, it's common to have a component track its own data, view, and handle updates to that view. In Elm, we _could_ follow that methodology with `Model/Msg` and `init/update/view`, but it's not ideal.

Unlike in JS, our `view` functions can only return one type of `msg`. This means using `Html.map` and `Cmd.map` every time you want to use a component. That can become a mess when you begin nesting components!

Modules should be [built around data structures](https://www.youtube.com/watch?v=XpDsk374LDE), and it's easier to reuse functions rather than nesting `update` functions:

### Making a Carousel Component

Let's outline the high-level API for the component, we'll provide the complete implementation later!

```elm
module Components.Carousel exposing
  ( Carousel
  , create
  , next, previous, select
  , view
  )

type Carousel slide

create : slide -> List slide -> Carousel slide

next : Carousel slide -> Carousel slide
previous : Carousel slide -> Carousel slide
select : Int -> Carousel slide -> Carousel slide

view :
  { carousel : Carousel slide
  , onNext : msg
  , onPrevious : msg
  , onSelect : Int -> msg
  , viewSlide : slide -> Html msg
  }
  -> Html msg
```

The above example shows a file that provides:

1. A new data structure– `Carousel`
1. Functions to update that structure:
   `next`, `previous`, and `select`
1. The way to `view` that structure

The implementation for `Carousel` isn't exposed, so callers won't break if you change it later. If you'd like to see the full Carousel implementation, [here it is](https://gist.github.com/ryannhg/b26c0d6a5d2bfd74643e7da6543c5170).

### Using a Carousel Component

Here's how you might call it in a page:

```elm
import Components.Carousel as Carousel exposing (Carousel)


type alias Model =
  { testimonials : Carousel Testimonial
  }

type alias Testimonial =
  { quote : String
  , author : String
  }

init : Model
init =
  { testimonials =
      Carousel.create
        { quote = "Cats have ears", author = "Ryan" }
        [ { quote = "Dogs also have ears", author = "Alexa" }
        , { quote = "I have ears", author = "Erik" }
        ]
  }
```

```elm
type Msg
  = NextTestimonial
  | PreviousTestimonial
  | SelectTestimonial Int

update : Msg -> Model -> Model
update msg model =
  case msg of
    NextTestimonial ->
      { model | testimonials = Carousel.next model.testimonials }

    PreviousTestimonial ->
      { model | testimonials = Carousel.previous model.testimonials }

    SelectTestimonial index ->
      { model | testimonials = Carousel.select index model.testimonials }
```

```elm
view : Model -> Html Msg
view model =
  div [ class "page" ]
      [ Carousel.view
          { carousel = model.testimonials
          , onNext = NextTestimonial
          , onPrevious = PreviousTestimonial
          , onSelect = SelectTestimonial
          , viewSlide = viewTestimonial
          }
      ]

viewTestimonial : Testimonial -> Html msg
viewTestimonial options =
  div [ class "testimonial" ]
      [ p [ class "quote" ] [ text options.quote ]
      , p [ class "author" ] [ text options.author ]
      ]
```

Just like before, we pass our `msg` types into the component, rather than give them their own special `Msg` types. Let your page handle those updates and your code will be much easier to read.

---

Next, let's talk about [using APIs](/guide/using-apis)

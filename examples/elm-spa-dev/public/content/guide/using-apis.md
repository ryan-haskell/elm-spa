# Using APIs

Most applications interact with a REST API or a GraphQL endpoint to access data. 
For this guide, we'll be using the [Reddit REST API](https://www.reddit.com/dev/api/#GET_hot) to fetch the latest posts from [r/elm](https://www.reddit.com/r/elm).
## Defining a module

Just like before, we'll define modules based on data structures:

```elm
module Api.Reddit.Listing exposing
  ( Listing
  , hot, new, top
  )
```

## Storing the data

In Elm, there's a better way to model API data other than just toggling a `loading` boolean from `true` to `false`. Using [the RemoteData pattern](https://www.youtube.com/watch?v=NLcRzOyrH08), we can represent all states data from the web might be in, and display the right thing to our users:

```elm
module Api exposing (Data(..), expectJson)

type Data value
    = NotAsked
    | Loading
    | Failure Http.Error
    | Success value

expectJson : (Data value -> msg) -> Decoder value -> Expect msg
```

The `expectJson` function is a replacement for [Http.expectJson](https://package.elm-lang.org/packages/elm/http/latest/Http#expectJson) which uses `Result` instead.

## Working with JSON

The [elm/json](https://package.elm-lang.org/packages/elm/json/latest) package allows us to handle JSON from APIs, without crashing our application if the JSON isn't what we initially expected. We do that by creating decoders:

```elm
import Json.Decode as Json

type alias Listing =
  { title : String
  , author : String
  , url : String
  }

decoder : Json.Decoder Listing
decoder =
  Json.map3 Listing
    (Json.field "title" Json.string)
    (Json.field "author_fullname" Json.string)
    (Json.field "url" Json.string)
```

## Actually fetching listings

Let's combine our new `Api` and `decoder` to actually fetch those Reddit posts! We'll use the [elm/http](https://package.elm-lang.org/packages/elm/http/latest) to make the GET request.

```elm
hot : { onResponse : Api.Data (List Listing) -> msg } -> Cmd msg
hot options =
  Http.get
    { url = "https://api.reddit.com/r/elm/hot"
    , expect =
        Api.expectJson options.onResponse
            (Json.at [ "data", "children" ] (Json.list decoder))
    }
```

The actual listings are located inside `data.children`, so we used `Json.at` and `Json.list` to before we use our `decoder`.

```javascript
{ "data": { "children": [ ... ] } }
```

We can reuse that code to implement `new` and `top`. Let's move the reusable bits into `listings`, and just pass in the endpoint as a string.

```elm
-- API ENDPOINTS

hot : { onResponse : Api.Data (List Listing) -> msg } -> Cmd msg
hot =
  listings "hot"


new : { onResponse : Api.Data (List Listing) -> msg } -> Cmd msg
new =
  listings "new"


top : { onResponse : Api.Data (List Listing) -> msg } -> Cmd msg
top =
  listings "top"


listings :
  String
  -> { onResponse : Api.Data (List Listing) -> msg }
  -> Cmd msg
listings endpoint options =
  Http.get
    { url = "https://api.reddit.com/r/elm/" ++ endpoint
    , expect =
        Api.expectJson options.onResponse
          (Json.at [ "data", "children" ] (Json.list decoder))
    }
```

## Calling the API

Now that we have our new `Api.Reddit.Listing` module, we can use it in our pages. Here's an example of what that looks like:

```elm
import Api
import Api.Reddit.Listing exposing (Listing)

type alias Model =
  { listings : Api.Data (List Listing)
  }

init : Url Params -> ( Model, Cmd Msg )
init url =
  ( Model Api.Loading
  , Api.Reddit.Listing.hot
      { onResponse = GotHotListings
      }
  )
```

This sends an initial request to fetch the top Reddit posts from r/elm. We need to handle the response in our update function.

```elm
type Msg
  = GotHotListings (Api.Data (List Listing))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GotHotListings data ->
      ( { model | listings = data }
      , Cmd.none
      )
```

Notice how we stored the entire `Api.Data` response, whether it succeeded or failed? That's perfect for the next bit, where we have control over how to show the user the state of the listings:

```elm
view : Model -> Document Msg
view model =
  { title = "Posts"
  , body =
    [ div [ class "page" ]
          [ viewListings model.listings
          ]
    ]
  }

viewListings : Api.Data (List Listing) -> Html msg
viewListings data =
  case data of
    Api.NotAsked -> text "Not asked"
    Api.Loading -> text "Loading..."
    Api.Failure _ -> text "Something went wrong..."
    Api.Success listings ->
      div [ class "listings" ]
          (List.map viewListing listings)

viewListing : Listing -> Html msg
viewListing listing =
  div [ class "listing" ]
      [ a [ class "title", href listing.url ]
          [ text listing.title ]
      , p [ class "author" ]
          [ text ("Author: " ++ listing.author) ]
      ]
```

That's it! Here are the [actual files](https://gist.github.com/ryannhg/3ce83ec17ed473717e5604c7047e4d2c) used for this section.

---

Next we'll go [Beyond HTML](/guide/beyond-html), to explore other view options.
module Pages.Guide exposing (Model, Msg, Params, page)

import Api.Data exposing (Data)
import Api.Markdown
import Components.Markdown
import Html exposing (..)
import Html.Attributes exposing (class)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route exposing (Route)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


type alias Params =
    ()


type alias Model =
    { route : Route
    , content : Data String
    }


page : Page Params Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


init : Url Params -> ( Model, Cmd Msg )
init { rawUrl } =
    ( { route = Route.fromUrl rawUrl |> Maybe.withDefault Route.NotFound
      , content = Api.Data.Loading
      }
    , Api.Markdown.get
        { file = "guide.md"
        , onResponse = GotMarkdown
        }
    )


type Msg
    = GotMarkdown (Data String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMarkdown content ->
            ( { model | content = content }
            , Cmd.none
            )


view : Model -> Document Msg
view model =
    { title = "guide | elm-spa"
    , body =
        [ Api.Data.view
            Components.Markdown.view
            model.content
        ]
    }

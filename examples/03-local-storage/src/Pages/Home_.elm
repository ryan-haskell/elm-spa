module Pages.Home_ exposing (Model, Msg, init, page, update, view)

import Html
import Html.Events
import Page
import Request exposing (Request)
import Shared
import Storage exposing (Storage)
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.element
        { init = init
        , update = update shared.storage
        , view = view shared.storage
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Storage -> Msg -> Model -> ( Model, Cmd Msg )
update storage msg model =
    case msg of
        Increment ->
            ( model
            , Storage.increment storage
            )

        Decrement ->
            ( model
            , Storage.decrement storage
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Storage -> Model -> View Msg
view storage _ =
    { title = "Homepage"
    , body =
        [ Html.h1 [] [ Html.text "Local storage" ]
        , Html.button [ Html.Events.onClick Increment ] [ Html.text "+" ]
        , Html.p [] [ Html.text ("Count: " ++ String.fromInt storage.counter) ]
        , Html.button [ Html.Events.onClick Decrement ] [ Html.text "-" ]
        ]
    }

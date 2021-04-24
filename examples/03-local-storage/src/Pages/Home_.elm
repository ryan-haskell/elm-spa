module Pages.Home_ exposing (Model, Msg, init, page, update, view)

import Gen.Params.Home_ exposing (Params)
import Html exposing (Html)
import Html.Events
import Page
import Ports
import Request
import Shared
import Storage exposing (Storage)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
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
            , Ports.save (Storage.increment storage)
            )

        Decrement ->
            ( model
            , Ports.save (Storage.decrement storage)
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Storage -> Model -> View Msg
view storage model =
    { title = "Homepage"
    , body =
        [ Html.h1 [] [ Html.text "Local storage" ]
        , Html.button [ Html.Events.onClick Increment ] [ Html.text "+" ]
        , Html.p [] [ Html.text ("Count: " ++ String.fromInt storage.counter) ]
        , Html.button [ Html.Events.onClick Decrement ] [ Html.text "-" ]
        ]
    }

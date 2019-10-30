module Pages.Counter exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page exposing (Page)
import Html exposing (..)
import Html.Events as Events


type alias Model =
    { counter : Int
    }


type Msg
    = Increment
    | Decrement


page : Page () Model Msg a b c d e
page =
    Page.sandbox
        { title = always "Counter"
        , init = always init
        , update = update
        , view = view
        }


init : Model
init =
    { counter = 0
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Counter" ]
        , div []
            [ button [ Events.onClick Decrement ] [ text "-" ]
            , p [] [ text (String.fromInt model.counter) ]
            , button [ Events.onClick Increment ] [ text "+" ]
            ]
        ]

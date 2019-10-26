module Pages.Counter exposing
    ( Model
    , Msg
    , Route
    , page
    )

import Application.Page as Application
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events


type alias Model =
    { counter : Int
    }


type Msg
    = Increment
    | Decrement


type alias Route =
    ()


page =
    Application.sandbox
        { init = always init
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
            , p []
                [ a [ Attr.href "/#section" ] [ text "bottom of homepage" ]
                ]
            ]
        ]

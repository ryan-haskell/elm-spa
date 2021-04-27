module Pages.Sandbox exposing (Model, Msg, page)

import Gen.Params.Sandbox exposing (Params)
import Html
import Html.Events
import Page
import Request
import Shared
import UI
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    { counter : Int
    }


init : Model
init =
    { counter = 0
    }



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Sandbox"
    , body =
        UI.layout
            [ UI.h1 "Sandbox"
            , Html.p [] [ Html.text "A sandbox page can keep track of state!" ]
            , Html.h3 [] [ Html.text (String.fromInt model.counter) ]
            , Html.button [ Html.Events.onClick Decrement ] [ Html.text "-" ]
            , Html.button [ Html.Events.onClick Increment ] [ Html.text "+" ]
            ]
    }

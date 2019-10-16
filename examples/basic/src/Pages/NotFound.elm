module Pages.NotFound exposing (Model, Msg, page)

import Application
import Html exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


page =
    Application.static
        { view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Page not found..." ]
        , p [] [ text "what a shame!" ]
        ]

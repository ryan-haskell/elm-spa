module Pages.NotFound exposing
    ( Model
    , Msg
    , Route
    , page
    )

import Application.Page as Application
import Html exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


type alias Route =
    ()


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

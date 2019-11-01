module Pages.NotFound exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
import Html exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


page =
    Page.static
        { title = "Page not found"
        , view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Page not found..." ]
        , p [] [ text "what a shame!" ]
        ]

module Pages.Index exposing
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
        { title = "elm-spa"
        , view = view
        }


view =
    div []
        [ h1 [] [ text "Homepage" ]
        , h3 [] [ text "Welcome to elm-spa!" ]
        , p []
            [ text "You should edit "
            , code [] [ text "src/Pages/Index.elm" ]
            , text " and see what happens!"
            ]
        ]

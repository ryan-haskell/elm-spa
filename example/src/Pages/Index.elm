module Pages.Index exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page exposing (Page)
import Html exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


page : Page () Model Msg a b c d e
page =
    Page.static
        { title = "Homepage"
        , view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Homepage" ]
        , p [] [ text "How exciting!" ]
        ]

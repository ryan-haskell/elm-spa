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
        { title = "Homepage"
        , view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Homepage" ]
        , p [] [ text "How exciting!" ]
        ]

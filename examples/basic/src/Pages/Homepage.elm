module Pages.Homepage exposing
    ( Model
    , Msg
    , page
    )

import Application
import Html exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


page : Application.Page Model Msg model msg
page =
    Application.static
        { view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Homepage" ]
        , p [] [ text "Very boring tho..." ]
        ]

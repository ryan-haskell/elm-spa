module Sandbox.Pages.Homepage exposing (Model, Msg, page)

import Application.Sandbox as Application
import Html exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


page : Application.Static
page =
    { view = view
    }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Homepage" ]
        , p [] [ text "Very boring tho..." ]
        ]

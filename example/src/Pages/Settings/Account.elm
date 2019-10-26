module Pages.Settings.Account exposing
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
    h2 [] [ text "Account" ]

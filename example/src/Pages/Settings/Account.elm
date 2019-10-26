module Pages.Settings.Account exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Application
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
    h2 [] [ text "Account" ]

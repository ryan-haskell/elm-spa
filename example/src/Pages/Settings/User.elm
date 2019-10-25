module Pages.Settings.User exposing
    ( Model
    , Msg
    , Route
    , page
    )

import Application
import Html exposing (..)


type alias Model =
    ()


type alias Msg =
    Never


type alias Route =
    ()


page : Application.Page Route Model Msg model msg
page =
    Application.static
        { view = view
        }


view : Html Msg
view =
    h2 [] [ text "User" ]

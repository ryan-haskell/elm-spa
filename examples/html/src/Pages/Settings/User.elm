module Pages.Settings.User exposing
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
        { title = "User Settings"
        , view = view
        }


view : Html Msg
view =
    h2 [] [ text "User" ]

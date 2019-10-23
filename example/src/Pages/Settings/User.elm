module Pages.Settings.User exposing
    ( Model
    , Msg
    , Params
    , page
    )

import Application
import Html exposing (..)
import Url.Parser as Parser


type alias Model =
    ()


type alias Msg =
    Never


type alias Params =
    ()


page : Application.Page Params Model Msg route model msg
page =
    Application.static
        { route = Parser.s "user" |> Parser.map ()
        , view = view
        }


view : Html Msg
view =
    h3 [] [ text "User" ]

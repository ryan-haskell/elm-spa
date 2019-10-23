module Pages.NotFound exposing
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
        { route = Parser.s "not-found" |> Parser.map ()
        , view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Page not found..." ]
        , p [] [ text "what a shame!" ]
        ]

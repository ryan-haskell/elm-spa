module Pages.Guide.Programming exposing (Model, Msg, page)

import Spa.Page
import Components.Hero
import Element exposing (..)
import Generated.Guide.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Programming Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "Guide.Programming"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column [ width fill ]
        [ Components.Hero.view
            { title = "programming"
            , subtitle = text "become nerdy, in an awful way"
            , buttons = []
            }
        ]

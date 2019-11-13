module Pages.Docs.Static exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Docs.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Static Model Msg model msg appMsg
page =
    App.Page.static
        { title = always "Static"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column
        [ width fill
        ]
        [ Components.Hero.view
            { title = "static tho"
            , subtitle = text "\"it's not done until the docs are great.\""
            , buttons = []
            }
        ]

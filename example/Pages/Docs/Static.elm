module Pages.Docs.Static exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Docs.Flags as Flags
import Utils.Page exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags.Static Model Msg model msg appMsg
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

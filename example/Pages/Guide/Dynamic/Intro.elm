module Pages.Guide.Dynamic.Intro exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Guide.Dynamic.Flags as Flags
import Utils.Page exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags.Intro Model Msg model msg appMsg
page =
    App.Page.static
        { title = always "Guide.Dynamic.Intro"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column
        [ width fill
        ]
        [ Components.Hero.view
            { title = "intro"
            , subtitle = text "\"you're gonna be great.\""
            , buttons = []
            }
        ]

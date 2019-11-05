module Pages.Guide.Elm exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Guide.Flags as Flags
import Utils.Page exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags.Elm Model Msg model msg appMsg
page =
    App.Page.static
        { title = always "Guide.Elm"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column [ width fill ]
        [ Components.Hero.view
            { title = "intro to elm"
            , subtitle = text "\"you're gonna be great.\""
            , buttons = []
            }
        ]

module Pages.Guide.Programming exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Guide.Flags as Flags
import Utils.Page exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags.Programming Model Msg model msg appMsg
page =
    App.Page.static
        { title = always "Guide.Programming"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column [ width fill ]
        [ Components.Hero.view
            { title = "programming"
            , subtitle = text "become nerdy, in a lovable way"
            , buttons = []
            }
        ]

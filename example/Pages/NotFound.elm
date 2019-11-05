module Pages.NotFound exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Flags as Flags
import Utils.Page exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags.NotFound Model Msg model msg appMsg
page =
    App.Page.static
        { title = always "NotFound"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column [ width fill ]
        [ Components.Hero.view
            { title = "that's not a place."
            , subtitle = text "but i'm not even mad about it."
            , buttons =
                [ { label = text "back home", action = Components.Hero.Link "/" }
                ]
            }
        ]

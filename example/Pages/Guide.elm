module Pages.Guide exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Flags as Flags
import Utils.Page exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags.Guide Model Msg model msg appMsg
page =
    App.Page.static
        { title = always "Guide"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column
        [ width fill ]
        [ Components.Hero.view
            { title = "guide"
            , subtitle = text "alright, where should we begin?"
            , buttons =
                [ { label = text "new to web dev", action = Components.Hero.Link "/guide/programming" }
                , { label = text "new to elm", action = Components.Hero.Link "/guide/elm" }
                , { label = text "new to elm-spa", action = Components.Hero.Link "/guide/elm-spa" }
                ]
            }
        ]

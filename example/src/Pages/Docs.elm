module Pages.Docs exposing (Model, Msg, page)

import App.Page
import Components.Hero
import Element exposing (..)
import Generated.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Docs Model Msg model msg appMsg
page =
    App.Page.static
        { title = always "Docs"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    column [ width fill ]
        [ Components.Hero.view
            { title = "docs"
            , subtitle = text "\"it's not done until the docs are great.\""
            , buttons =
                [ { label = text "elm-app", action = Components.Hero.Link "/docs/elm-app" }
                , { label = text "elm-spa", action = Components.Hero.Link "/docs/elm-spa" }
                ]
            }
        ]

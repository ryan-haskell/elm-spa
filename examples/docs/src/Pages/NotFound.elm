module Pages.NotFound exposing (Model, Msg, page)

import Components.Hero as Hero
import Element exposing (..)
import Element.Font as Font
import Generated.Params as Params
import Generated.Routes as Routes exposing (routes)
import Spa.Page
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.NotFound Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "not found | elm-spa"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    Hero.view
        { title = "page not found?"
        , subtitle = "it's not you, it's me."
        , links =
            [ { label = "but this link works!"
              , url = "/"
              }
            ]
        }

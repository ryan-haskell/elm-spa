module Pages.NotFound exposing (Model, Msg, page)

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
    column [ centerX, centerY, spacing 16 ]
        [ el [ Font.size 32, Font.semiBold ] (text "404 is life.")
        , link [ Font.size 16, Font.underline, centerX, Font.color (rgb255 204 75 75), mouseOver [ alpha 0.5 ] ]
            { label = text "back home?"
            , url = Routes.toPath routes.top
            }
        ]

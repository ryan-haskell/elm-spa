module Pages.NotFound exposing (Model, Msg, page)

import Application.Page as Page
import Element exposing (..)
import Element.Font as Font


type alias Model =
    ()


type alias Msg =
    Never


page =
    Page.static
        { title = "Page not found"
        , view = view
        }


view : Element Msg
view =
    column [ spacing 16 ]
        [ text "Page not found"
        , link
            [ Font.underline
            , Font.size 16
            , Font.color (rgb 0 0.6 0.75)
            ]
            { label = text "Go home", url = "/" }
        ]

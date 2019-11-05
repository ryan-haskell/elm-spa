module Pages.SomePage exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
import Html exposing (..)
import Html.Attributes as Attr


type alias Model =
    ()


type alias Msg =
    Never


page =
    Page.static
        { title = "some page | elm-spa"
        , view = view
        }


view : Html msg
view =
    div []
        [ h1 [] [ text "This is some page!" ]
        ]

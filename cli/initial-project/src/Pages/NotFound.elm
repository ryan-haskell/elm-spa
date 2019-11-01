module Pages.NotFound exposing
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
        { title = "not found | elm-spa"
        , view =
            div []
                [ h1 [] [ text "Page not found!" ]
                , p [] [ a [ Attr.href "/" ] [ text "Back to homepage" ] ]
                ]
        }

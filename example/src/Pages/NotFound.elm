module Pages.NotFound exposing
    ( Flags
    , Model
    , Msg
    , page
    )

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Spa exposing (Page)


type alias Flags =
    ()


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags Model Msg globalModel globalMsg
page =
    Spa.static
        { view = view
        }


view : Document msg
view =
    { title = "NotFound"
    , body =
        [ h1 [ class "font--h1" ] [ text "Page not found..." ]
        ]
    }

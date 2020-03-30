module Pages.Top exposing (Flags, Model, Msg, page)

import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Page exposing (Document, Page)


type alias Flags =
    ()


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags Model Msg
page =
    Page.static
        { view = view
        }


view : Document Msg
view =
    { title = "Homepage"
    , body =
        [ h1 [ class "font--h1" ] [ text "Homepage" ]
        ]
    }

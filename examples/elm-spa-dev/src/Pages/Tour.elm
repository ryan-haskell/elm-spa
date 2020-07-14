module Pages.Tour exposing (Model, Msg, Params, page)

import Html exposing (div, h1, p, text)
import Html.Attributes exposing (class)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }


type alias Model =
    Url Params


type alias Msg =
    Never



-- VIEW


type alias Params =
    ()


view : Url Params -> Document Msg
view { params } =
    { title = "Tour"
    , body =
        [ div [ class "column spacing-tiny py-large center-x text-center" ]
            [ h1 [ class "font-h1" ] [ text "tour" ]
            , p [ class "font-h5 color--faint" ] [ text "coming soon!" ]
            ]
        ]
    }

module Pages.NotFound exposing (Model, Msg, Params, page, view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }


type alias Params =
    ()


type alias Model =
    Url Params


type alias Msg =
    Never


view : Url Params -> Document Msg
view _ =
    { title = "404"
    , body =
        [ div [ class "column spacing-tiny" ]
            [ h1 [ class "font-h2" ] [ text "Page not found" ]
            , p [ class "font-body color--faint" ]
                [ text "How about the "
                , a [ class "link", href (Route.toString Route.Top) ] [ text "homepage" ]
                , text "? That's a nice place."
                ]
            ]
        ]
    }

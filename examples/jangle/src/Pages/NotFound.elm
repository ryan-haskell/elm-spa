module Pages.NotFound exposing (Model, Msg, Params, page)

import Api.User exposing (User)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events as Events
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)


type alias Params =
    ()


type alias Model =
    Page.Protected Params { user : User, url : Url Params }


type alias Msg =
    Never


page : Page Params Model Msg
page =
    Page.protectedStatic
        { view = view
        }


view : User -> Url Params -> Document Msg
view _ _ =
    { title = "Jangle"
    , body =
        [ div [ class "column fill center" ]
            [ div [ class "column bg--white padding-medium shadow spacing-small max-width--20 rounded-tiny fill-x center-x" ]
                [ h1 [ class "font-h2 text-center" ] [ text "Page not Found" ]
                , div [ class "row" ]
                    [ a [ class "button", href (Route.toString Route.Top) ] [ text "Back to projects" ]
                    ]
                ]
            ]
        ]
    }

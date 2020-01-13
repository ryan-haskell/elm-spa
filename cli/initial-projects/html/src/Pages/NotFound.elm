module Pages.NotFound exposing (Model, Msg, page)

import Generated.Params as Params
import Generated.Routes as Routes exposing (routes)
import Html exposing (..)
import Html.Attributes as Attr
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


view : Html Msg
view =
    div [ Attr.class "page" ]
        [ h1
            [ Attr.class "page__title" ]
            [ text "404 is life." ]
        , a
            [ Attr.class "page__link"
            , Attr.href (Routes.toPath routes.top)
            ]
            [ text "back home?" ]
        ]

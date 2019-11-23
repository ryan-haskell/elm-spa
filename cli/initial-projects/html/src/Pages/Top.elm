module Pages.Top exposing (Model, Msg, page)

import Generated.Params as Params
import Html exposing (..)
import Html.Attributes as Attr
import Spa.Page
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Top Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "homepage"
        , view = always view
        }



-- VIEW


view : Html Msg
view =
    div [ Attr.class "page" ]
        [ h1
            [ Attr.class "page__title" ]
            [ text "404 is life." ]
        , p [ Attr.class "page__subtitle" ]
            [ text "(you're doing great already!)" ]
        , a
            [ Attr.class "page__link"
            , Attr.target "_blank"
            , Attr.href "https://elm-spa.dev"
            ]
            [ text "learn more"
            ]
        ]

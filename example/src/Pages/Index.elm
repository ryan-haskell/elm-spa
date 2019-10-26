module Pages.Index exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page exposing (Page)
import Html exposing (..)
import Html.Attributes as Attr


type alias Model =
    ()


type alias Msg =
    Never


page : Page () Model Msg a b c d e
page =
    Page.static
        { view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Homepage" ]
        , p [] [ text "How exciting!" ]
        , a [ Attr.href "#section" ] [ text "jump link" ]
        , div [ Attr.style "height" "200vh" ] []
        , h3 [ Attr.id "section" ] [ text "you found me!" ]
        , p [] [ text "(and i'm not even mad)" ]
        ]

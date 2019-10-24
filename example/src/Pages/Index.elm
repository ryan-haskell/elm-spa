module Pages.Index exposing
    ( Model
    , Msg
    , Route
    , page
    )

import Application
import Html exposing (..)
import Html.Attributes as Attr


type alias Model =
    ()


type alias Msg =
    Never


type alias Route =
    ()


page : Application.Page Route Model Msg model msg
page =
    Application.static
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

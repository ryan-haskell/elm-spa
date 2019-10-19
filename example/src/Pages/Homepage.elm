module Pages.Homepage exposing
    ( Model
    , Msg
    , Params
    , page
    )

import Application
import Html exposing (..)
import Html.Attributes exposing (href, id, style)


type alias Model =
    ()


type alias Msg =
    Never


type alias Params =
    ()


page : Application.Page Params Model Msg model msg
page =
    Application.static
        { view = view
        }


view : Html Msg
view =
    div []
        [ h1 [] [ text "Homepage" ]
        , p [] [ text "How exciting!" ]
        , a [ href "#section" ] [ text "scroll bois" ]
        , div [ style "height" "200vh" ] []
        , h3 [ id "section" ] [ text "hey thur" ]
        , p [] [ text "How exciting!" ]
        ]

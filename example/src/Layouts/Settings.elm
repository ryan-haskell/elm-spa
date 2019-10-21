module Layouts.Settings exposing (layout)

import Application
import Html exposing (..)
import Html.Attributes exposing (href, style)


layout : Application.Layout msg
layout =
    { view = view
    , transition = Application.none
    }


view : { page : Html msg } -> Html msg
view { page } =
    div []
        [ h1 [] [ text "Settings" ]
        , p [] <|
            List.map viewLink
                [ ( "Account", "account" )
                , ( "Notifications", "notifications" )
                , ( "User", "user" )
                ]
        , page
        ]


viewLink : ( String, String ) -> Html msg
viewLink ( label, slug ) =
    a
        [ style "margin-right" "1rem"
        , href ("/settings/" ++ slug)
        ]
        [ text label
        ]

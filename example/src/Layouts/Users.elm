module Layouts.Users exposing (layout)

import Application.Page as Page
import Application.Transition as Transition
import Global
import Html exposing (..)
import Html.Attributes as Attr


layout : Page.LayoutOptions Global.Model msg
layout =
    { transition = Transition.none
    , view = view
    }


view : { page : Html msg, global : Global.Model } -> Html msg
view { page } =
    div []
        [ div []
            (List.map
                (\link ->
                    a
                        [ Attr.href <| "/users/" ++ link
                        , Attr.style "margin-right" "8px"
                        ]
                        [ text link ]
                )
                [ "alice", "bob" ]
            )
        , page
        ]

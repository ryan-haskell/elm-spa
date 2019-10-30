module Layouts.Users exposing (view)

import Global
import Html exposing (..)
import Html.Attributes as Attr


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

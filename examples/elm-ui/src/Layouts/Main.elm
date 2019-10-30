module Layouts.Main exposing (view)

import Element exposing (..)
import Element.Font as Font
import Global


view : { page : Element msg, global : Global.Model } -> Element msg
view { page, global } =
    column
        [ padding 32
        , spacing 32
        , width fill
        , height fill
        ]
        [ navbar global
        , page
        ]


navbar : Global.Model -> Element msg
navbar model =
    row
        [ width fill
        , spacing 32
        ]
        [ row [ spacing 16 ]
            (List.map viewLink [ ( "Home", "/" ), ( "Sign in", "/sign-in" ) ])
        , el [ alignRight ]
            (model.user
                |> Maybe.map (\name -> "signed in as: " ++ name)
                |> Maybe.withDefault "not signed in"
                |> text
                |> el [ alpha 0.6 ]
            )
        ]


viewLink : ( String, String ) -> Element msg
viewLink ( label, url ) =
    link
        [ Font.color colors.blue
        , Font.underline
        , Font.size 16
        ]
        { label = text label, url = url }


colors =
    { blue = rgb 0 0.5 0.75
    }

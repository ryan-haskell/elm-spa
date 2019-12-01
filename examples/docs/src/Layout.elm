module Layout exposing (view)

import Components.Navbar as Navbar
import Element exposing (..)
import Element.Font as Font
import Element.Region as Region
import Ui
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    column
        [ height fill
        , width (fill |> maximum 780)
        , centerX
        , Font.size 16
        , Font.family
            [ Font.external
                { name = "Source Sans Pro"
                , url = "https://fonts.googleapis.com/css?family=Source+Sans+Pro:400,400i,600,600i"
                }
            , Font.sansSerif
            ]
        , paddingEach
            { top = 32
            , left = 20
            , right = 20
            , bottom = 0
            }
        ]
        [ el [ Region.navigation, width fill ] (Navbar.view route)
        , el [ Region.mainContent, width fill, height fill ] page
        , el [ Region.footer, width fill ] viewFooter
        ]


viewFooter : Element msg
viewFooter =
    row
        [ width fill
        , paddingEach { top = 96, left = 0, right = 0, bottom = 48 }
        , alpha 0.5
        ]
        [ text "this site was built with elm-spa!"
        , newTabLink [ alignRight, Font.underline ]
            { label = text "github"
            , url = "https://github.com/ryannhg/elm-spa"
            }
        ]

module Layouts.Guide exposing (view)

import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (routes)
import Ui
import Utils.Spa as Spa


paddingTop : Int -> Attribute msg
paddingTop value =
    paddingEach
        { top = value
        , left = 0
        , right = 0
        , bottom = 0
        }


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    el
        [ paddingEach
            { top = 32
            , left = 0
            , right = 0
            , bottom = 0
            }
        , width fill
        , centerX
        , onLeft <|
            column
                [ alignTop
                , spacing 12
                , width (px 150)
                , paddingEach
                    { top = 96
                    , left = 32
                    , right = 0
                    , bottom = 0
                    }
                ]
                [ el [ Font.semiBold, Font.size 24 ] (text "guide")
                , column [ spacing 8 ] <|
                    List.map
                        (\option ->
                            link
                                (if option.route == route then
                                    Ui.styles.link.disabled

                                 else
                                    Ui.styles.link.enabled
                                )
                                { label = text option.label
                                , url = Routes.toPath option.route
                                }
                        )
                        [ { label = "setup", route = routes.guide_dynamic "setup" }
                        , { label = "deploying", route = routes.guide_dynamic "deploying" }
                        ]
                ]
        ]
        page

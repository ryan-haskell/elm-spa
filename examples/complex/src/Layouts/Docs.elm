module Layouts.Docs exposing (transition, view)

import App.Transition as Transition exposing (Transition)
import Components.Styles as Styles
import Element exposing (..)
import Element.Font as Font
import Generated.Routes as Routes exposing (Route, routes)
import Global
import Utils.Spa as Spa


transition : Transition (Element msg)
transition =
    Transition.custom
        { speed = 500
        , invisible =
            \{ layout, page } ->
                layout <|
                    el
                        [ alpha 0
                        , width fill
                        , rotate (4 * pi)
                        , scale 0
                        , Styles.transition
                            { property = "all"
                            , speed = 500
                            }
                        ]
                        page
        , visible =
            \{ layout, page } ->
                layout <|
                    el
                        [ alpha 1
                        , width fill
                        , Styles.transition
                            { property = "all"
                            , speed = 500
                            }
                        ]
                        page
        }


view : Spa.LayoutContext msg -> Element msg
view { page, route } =
    column [ width fill ]
        [ row [ spacing 16 ] <|
            List.map (viewLink route)
                [ { label = "elm"
                  , route = routes.docs_dynamic "elm"
                  }
                , { label = "elm-spa"
                  , route = routes.docs_dynamic "elm-spa"
                  }
                ]
        , page
        ]


viewLink : Route -> { label : String, route : Route } -> Element msg
viewLink activeRoute { label, route } =
    if route == activeRoute then
        link
            [ Font.underline
            ]
            { url = Routes.toPath route
            , label = text label
            }

    else
        link
            Styles.link
            { url = Routes.toPath route
            , label = text label
            }

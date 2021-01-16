module Pages.Home_ exposing (page)

import Html exposing (..)
import Html.Attributes exposing (attribute, href, style)
import View exposing (View)


page : View Never
page =
    { title = "Homepage"
    , body =
        [ div
            [ style "font-family" "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif"
            , style "color" "#333"
            , style "padding" "4rem"
            ]
            [ h1 [] [ text "🎉  Hooray– it's working!" ]
            , p []
                [ strong [] [ text "Nice work! " ]
                , text "Learn more at "
                , a [ href "https://elm-spa.dev/guide", attribute "target" "_blank" ]
                    [ text "elm-spa.dev" ]
                ]
            ]
        ]
    }

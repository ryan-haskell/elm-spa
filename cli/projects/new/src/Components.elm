module Components exposing (layout)

import Browser exposing (Document)
import Generated.Route as Route exposing (Route)
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href, style)


layout : { page : Document msg } -> Document msg
layout { page } =
    { title = page.title
    , body =
        [ div [ class "column spacing--large pad--medium container h--fill" ]
            [ navbar
            , div [ class "column", style "flex" "1 0 auto" ] page.body
            , footer
            ]
        ]
    }


navbar : Html msg
navbar =
    header [ class "row center-y spacing--between" ]
        [ a [ class "link font--h5", href (Route.toHref Route.Top) ] [ text "home" ]
        , div [ class "row center-y spacing--medium" ]
            [ a [ class "link", href (Route.toHref Route.Docs) ] [ text "docs" ]
            , a [ class "link", href (Route.toHref Route.NotFound) ] [ text "a broken link" ]
            , a [ class "button", href "https://twitter.com/intent/tweet?text=elm-spa is ez pz" ] [ text "tweet about it" ]
            ]
        ]


footer : Html msg
footer =
    Html.footer [] [ text "built with elm ❤" ]

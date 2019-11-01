module Pages.Docs exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
import Html exposing (..)
import Html.Attributes as Attr


type alias Model =
    ()


type alias Msg =
    Never


page =
    Page.static
        { title = "docs | elm-spa"
        , view = view
        }


view : Html msg
view =
    div []
        [ h1 [] [ text "Docs" ]
        , h3 [] [ text "Want to learn more?" ]
        , p [] [ text "An official documentation site (built with elm-spa) is coming soon!" ]
        , p [] [ text "For now, feel free to check out:" ]
        , ul []
            (List.map viewBulletPoint
                [ ( "the github repo", "https://github.com/ryannhg/elm-spa" )
                , ( "the elm package docs", "https://package.elm-lang.org/packages/ryannhg/elm-spa/latest/" )
                , ( "the cli docs", "https://github.com/ryannhg/elm-spa/tree/master/cli" )
                ]
            )
        ]


viewBulletPoint : ( String, String ) -> Html msg
viewBulletPoint ( label, url ) =
    li []
        [ a
            [ Attr.href url
            , Attr.target "_blank"
            ]
            [ text label ]
        ]

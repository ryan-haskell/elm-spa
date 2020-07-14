module Api.Data exposing (Data(..), fromHttpResult, view)

import Html exposing (Html)
import Html.Attributes as Attr exposing (class, classList)
import Spa.Transition


type Data value
    = Loading
    | Success value
    | Failure String


fromHttpResult : Result error value -> Data value
fromHttpResult result =
    case result of
        Ok value ->
            Success value

        Err _ ->
            Failure "Either this is a broken link or there's missing documentation!"


view : (value -> Html msg) -> Data value -> Html msg
view toHtml data =
    Html.div
        [ classList [ ( "invisible", data == Loading ) ]
        , Attr.style "transition" Spa.Transition.properties.page
        ]
    <|
        case data of
            Loading ->
                []

            Success value ->
                [ toHtml value ]

            Failure reason ->
                [ Html.div [ class "column spacing-small" ]
                    [ Html.div [ class "column spacing-small" ]
                        [ Html.h1 [ class "font-h2" ] [ Html.text "well. that's weird." ]
                        , Html.p [] [ Html.text reason ]
                        ]
                    , Html.p []
                        [ Html.text "Could you please "
                        , Html.a
                            [ class "link"
                            , Attr.href "https://github.com/ryannhg/elm-spa/issues/new?labels=documentation&title=Broken%20docs%20link"
                            , Attr.target "_blank"
                            ]
                            [ Html.text "let me know?" ]
                        ]
                    ]
                ]

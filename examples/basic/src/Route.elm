module Route exposing (Route(..), fromUrl, title, toPath)

import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Homepage
    | Counter
    | Random
    | NotFound


fromUrl : Url -> Route
fromUrl =
    Parser.parse router >> Maybe.withDefault NotFound


router : Parser (Route -> Route) Route
router =
    Parser.oneOf
        [ Parser.map Homepage Parser.top
        , Parser.map Counter (Parser.s "counter")
        , Parser.map Random (Parser.s "random")
        ]


toPath : Route -> String
toPath route =
    (String.join "/" >> (++) "/") <|
        case route of
            Homepage ->
                []

            Counter ->
                [ "counter" ]

            Random ->
                [ "random" ]

            NotFound ->
                [ "not-found" ]


title : Route -> String
title route =
    case route of
        Homepage ->
            "Home"

        Counter ->
            "Counter"

        Random ->
            "Random"

        NotFound ->
            "Not found"

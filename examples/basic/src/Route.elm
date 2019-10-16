module Route exposing (Route(..), fromUrl, toPath)

import Url exposing (Url)
import Url.Parser as Parser


type Route
    = Homepage
    | Counter
    | Random
    | NotFound


fromUrl : Url -> Route
fromUrl =
    Parser.parse
        (Parser.oneOf
            [ Parser.map Homepage Parser.top
            , Parser.map Counter (Parser.s "counter")
            , Parser.map Random (Parser.s "random")
            ]
        )
        >> Maybe.withDefault NotFound


toPath : Route -> String
toPath route =
    case route of
        Homepage ->
            "/"

        Counter ->
            "/counter"

        Random ->
            "/random"

        NotFound ->
            "/not-found"

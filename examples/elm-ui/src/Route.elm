module Route exposing (Route(..), fromUrl, toPath)

import Url exposing (Url)
import Url.Parser as Parser


type Route
    = Homepage
    | NotFound


fromUrl : Url -> Route
fromUrl =
    let
        routes =
            Parser.oneOf
                [ Parser.map Homepage Parser.top
                ]
    in
    Parser.parse routes >> Maybe.withDefault NotFound


toPath : Route -> String
toPath route =
    case route of
        Homepage ->
            "/"

        NotFound ->
            "/not-found"

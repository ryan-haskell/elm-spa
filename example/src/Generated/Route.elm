module Generated.Route exposing (Route(..), fromUrl, toPath)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>))


type Route
    = Homepage
    | Counter
    | Random
    | Users_Slug String
    | NotFound


fromUrl : Url -> Route
fromUrl =
    Parser.parse
        (Parser.oneOf
            [ Parser.map Homepage Parser.top
            , Parser.map Counter (Parser.s "counter")
            , Parser.map Random (Parser.s "random")
            , Parser.map Users_Slug (Parser.s "users" </> Parser.string)
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

        Users_Slug slug ->
            "/users/" ++ slug

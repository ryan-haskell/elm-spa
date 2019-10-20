module Generated.Route exposing (Route(..), fromUrl, toPath)

import Generated.Route.Settings as Settings
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Homepage ()
    | Counter ()
    | Random ()
    | Settings Settings.Route
    | Users_Slug String
    | Users_Slug_Posts_Slug UserPostInfo
    | NotFound ()


type alias UserPostInfo =
    { user : String
    , post : Int
    }


fromUrl : Url -> Route
fromUrl =
    Parser.parse parser >> Maybe.withDefault (NotFound ())


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.top
            |> Parser.map (Homepage ())
        , Parser.s "counter"
            |> Parser.map (Counter ())
        , Parser.s "random"
            |> Parser.map (Random ())
        , Parser.s "settings"
            |> (</>) (Parser.map Settings Settings.parser)
        , (Parser.s "users" </> Parser.string)
            |> Parser.map Users_Slug
        , (Parser.s "users" </> Parser.string </> Parser.s "posts" </> Parser.int)
            |> Parser.map UserPostInfo
            |> Parser.map Users_Slug_Posts_Slug
        ]


toPath : Route -> String
toPath route =
    case route of
        Homepage _ ->
            "/"

        Counter _ ->
            "/counter"

        Random _ ->
            "/random"

        Settings r ->
            "/settings" ++ Settings.toPath r

        NotFound _ ->
            "/not-found"

        Users_Slug slug ->
            "/users/" ++ slug

        Users_Slug_Posts_Slug { user, post } ->
            "/users/" ++ user ++ "/posts/" ++ String.fromInt post

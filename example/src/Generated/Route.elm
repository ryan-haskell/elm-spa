module Generated.Route exposing (Route(..), fromUrl, toPath)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Homepage ()
    | Counter ()
    | Random ()
    | Users_Slug String
    | Users_Slug_Posts_Slug UserPostInfo
    | NotFound ()


type alias UserPostInfo =
    { user : String
    , post : Int
    }


fromUrl : Url -> Route
fromUrl =
    Parser.parse
        (Parser.oneOf routes)
        >> Maybe.withDefault (NotFound ())


routes : List (Parser (Route -> Route) Route)
routes =
    [ Parser.top
        |> Parser.map (Homepage ())
    , Parser.s "counter"
        |> Parser.map (Counter ())
    , Parser.s "random"
        |> Parser.map (Random ())
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

        NotFound _ ->
            "/not-found"

        Users_Slug slug ->
            "/users/" ++ slug

        Users_Slug_Posts_Slug { user, post } ->
            "/users/" ++ user ++ "/posts/" ++ String.fromInt post

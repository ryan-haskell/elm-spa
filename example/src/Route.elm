module Route exposing
    ( Route(..)
    , fromUrl
    , toHref
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = About
    | Authors_Dynamic_Posts_Dynamic { param1 : String, param2 : String }
    | Top
    | Posts_Top
    | Posts_Dynamic { param1 : String }
    | Profile
    | NotFound


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse routes


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Top Parser.top
        , Parser.map About (Parser.s "about")
        , Parser.map Posts_Top (Parser.s "posts")
        , Parser.map Profile (Parser.s "profile")
        , (Parser.s "posts" </> Parser.string)
            |> Parser.map (\param1 -> { param1 = param1 })
            |> Parser.map Posts_Dynamic
        , (Parser.s "authors" </> Parser.string </> Parser.s "posts" </> Parser.string)
            |> Parser.map (\param1 param2 -> { param1 = param1, param2 = param2 })
            |> Parser.map Authors_Dynamic_Posts_Dynamic
        ]


toHref : Route -> String
toHref route =
    let
        segments : List String
        segments =
            case route of
                Top ->
                    []

                About ->
                    [ "about" ]

                Authors_Dynamic_Posts_Dynamic { param1, param2 } ->
                    [ "authors", param1, "posts", param2 ]

                Posts_Top ->
                    [ "posts" ]

                Posts_Dynamic { param1 } ->
                    [ "posts", param1 ]

                Profile ->
                    [ "profile" ]

                NotFound ->
                    [ "not-found" ]
    in
    segments
        |> String.join "/"
        |> String.append "/"

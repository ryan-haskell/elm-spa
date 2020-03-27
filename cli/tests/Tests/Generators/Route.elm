module Tests.Generators.Route exposing (suite)

import Expect exposing (Expectation)
import Generators.Route as Route
import Path exposing (Path)
import Test exposing (..)


paths :
    { empty : List Path
    , single : List Path
    , multiple : List Path
    }
paths =
    { empty = []
    , single =
        [ Path.fromFilepath "Top.elm"
        ]
    , multiple =
        [ Path.fromFilepath "Top.elm"
        , Path.fromFilepath "About.elm"
        , Path.fromFilepath "NotFound.elm"
        , Path.fromFilepath "Posts/Top.elm"
        , Path.fromFilepath "Posts/Dynamic.elm"
        , Path.fromFilepath "Authors/Dynamic/Posts/Dynamic.elm"
        ]
    }


suite : Test
suite =
    describe "Generators.Route"
        [ describe "routeCustomType"
            [ test "returns empty for missing variants" <|
                \_ ->
                    paths.empty
                        |> Route.routeCustomType
                        |> Expect.equal ""
            , test "handles single path" <|
                \_ ->
                    paths.single
                        |> Route.routeCustomType
                        |> Expect.equal "type Route = Top"
            , test "handles multiple paths" <|
                \_ ->
                    paths.multiple
                        |> Route.routeCustomType
                        |> Expect.equal (String.trim """
type Route
    = Top
    | About
    | NotFound
    | Posts_Top
    | Posts_Dynamic { param1 : String }
    | Authors_Dynamic_Posts_Dynamic { param1 : String, param2 : String }
""")
            ]
        , describe "routeParsers"
            [ test "handles empty path" <|
                \_ ->
                    paths.empty
                        |> Route.routeParsers
                        |> Expect.equal "        []"
            , test "handles single path" <|
                \_ ->
                    paths.single
                        |> Route.routeParsers
                        |> Expect.equal "        [ Parser.map Top Parser.top ]"
            , test "handles multiple paths" <|
                \_ ->
                    paths.multiple
                        |> Route.routeParsers
                        |> Expect.equal """        [ Parser.map Top Parser.top
        , Parser.map About (Parser.s "about")
        , Parser.map NotFound (Parser.s "not-found")
        , Parser.map Posts_Top (Parser.s "posts")
        , (Parser.s "posts" </> Parser.string)
          |> Parser.map (\\param1 -> { param1 = param1 })
          |> Parser.map Posts_Dynamic
        , (Parser.s "authors" </> Parser.string </> Parser.s "posts" </> Parser.string)
          |> Parser.map (\\param1 param2 -> { param1 = param1, param2 = param2 })
          |> Parser.map Authors_Dynamic_Posts_Dynamic
        ]"""
            ]
        , describe "routeSegments"
            [ test "handles empty path" <|
                \_ ->
                    paths.empty
                        |> Route.routeSegments
                        |> Expect.equal ""
            , test "handles single path" <|
                \_ ->
                    paths.single
                        |> Route.routeSegments
                        |> Expect.equal """            case route of
                Top ->
                    []"""
            , test "handles multiple paths" <|
                \_ ->
                    paths.multiple
                        |> Route.routeSegments
                        |> Expect.equal """            case route of
                Top ->
                    []
                
                About ->
                    [ "about" ]
                
                NotFound ->
                    [ "not-found" ]
                
                Posts_Top ->
                    [ "posts" ]
                
                Posts_Dynamic { param1 } ->
                    [ "posts", param1 ]
                
                Authors_Dynamic_Posts_Dynamic { param1, param2 } ->
                    [ "authors", param1, "posts", param2 ]"""
            ]
        ]

module Tests.Path exposing (suite)

import Expect exposing (Expectation)
import Path exposing (Path)
import Test exposing (..)


suite : Test
suite =
    describe "Path"
        [ describe "routingOrder"
            [ test "prioritizes dynamic last" <|
                \_ ->
                    Path.routingOrder
                        (Path.fromFilepath "Example/Top.elm")
                        (Path.fromFilepath "Example/Dynamic.elm")
                        |> Expect.equal LT
            , test "prioritizes files over folders with top" <|
                \_ ->
                    Path.routingOrder
                        (Path.fromFilepath "Example/Top.elm")
                        (Path.fromFilepath "Example.elm")
                        |> Expect.equal GT
            , test "works with List.sortWith as expected" <|
                \_ ->
                    [ Path.fromFilepath "Top.elm"
                    , Path.fromFilepath "About.elm"
                    , Path.fromFilepath "Authors/Dynamic/Posts/Dynamic.elm"
                    , Path.fromFilepath "Posts/Dynamic.elm"
                    , Path.fromFilepath "Posts.elm"
                    , Path.fromFilepath "Posts/Top.elm"
                    ]
                        |> List.sortWith Path.routingOrder
                        |> Expect.equalLists
                            [ Path.fromFilepath "Top.elm"
                            , Path.fromFilepath "About.elm"
                            , Path.fromFilepath "Posts.elm"
                            , Path.fromFilepath "Posts/Top.elm"
                            , Path.fromFilepath "Posts/Dynamic.elm"
                            , Path.fromFilepath "Authors/Dynamic/Posts/Dynamic.elm"
                            ]
            ]
        , describe "fromFilepath"
            [ test "ignores first slash" <|
                \_ ->
                    "/Top.elm"
                        |> Path.fromFilepath
                        |> Path.toList
                        |> Expect.equalLists [ "Top" ]
            , test "works without folders" <|
                \_ ->
                    "Top.elm"
                        |> Path.fromFilepath
                        |> Path.toList
                        |> Expect.equalLists [ "Top" ]
            , test "works with a single folder" <|
                \_ ->
                    "Posts/Top.elm"
                        |> Path.fromFilepath
                        |> Path.toList
                        |> Expect.equalLists [ "Posts", "Top" ]
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Dynamic/Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.toList
                        |> Expect.equalLists [ "Authors", "Dynamic", "Posts", "Dynamic" ]
            ]
        , describe "toModulePath"
            [ test "works without folders" <|
                \_ ->
                    "Top.elm"
                        |> Path.fromFilepath
                        |> Path.toModulePath
                        |> Expect.equal "Top"
            , test "works with a single folder" <|
                \_ ->
                    "Posts/Top.elm"
                        |> Path.fromFilepath
                        |> Path.toModulePath
                        |> Expect.equal "Posts.Top"
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Dynamic/Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.toModulePath
                        |> Expect.equal "Authors.Dynamic.Posts.Dynamic"
            ]
        , describe "toVariableName"
            [ test "works without folders" <|
                \_ ->
                    "Top.elm"
                        |> Path.fromFilepath
                        |> Path.toVariableName
                        |> Expect.equal "top"
            , test "works correctly with capital letters" <|
                \_ ->
                    "NotFound.elm"
                        |> Path.fromFilepath
                        |> Path.toVariableName
                        |> Expect.equal "notFound"
            , test "works with a single folder" <|
                \_ ->
                    "Posts/Top.elm"
                        |> Path.fromFilepath
                        |> Path.toVariableName
                        |> Expect.equal "posts_top"
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Dynamic/Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.toVariableName
                        |> Expect.equal "authors_dynamic_posts_dynamic"
            ]
        , describe "toTypeName"
            [ test "works without folders" <|
                \_ ->
                    "Top.elm"
                        |> Path.fromFilepath
                        |> Path.toTypeName
                        |> Expect.equal "Top"
            , test "works with a single folder" <|
                \_ ->
                    "Posts/Top.elm"
                        |> Path.fromFilepath
                        |> Path.toTypeName
                        |> Expect.equal "Posts_Top"
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Dynamic/Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.toTypeName
                        |> Expect.equal "Authors_Dynamic_Posts_Dynamic"
            ]
        , describe "optionalParams"
            [ test "works without folders" <|
                \_ ->
                    "Top.elm"
                        |> Path.fromFilepath
                        |> Path.optionalParams
                        |> Expect.equal ""
            , test "works with a single folder" <|
                \_ ->
                    "Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.optionalParams
                        |> Expect.equal " { param1 : String }"
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Dynamic/Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.optionalParams
                        |> Expect.equal " { param1 : String, param2 : String }"
            ]
        , describe "toParser"
            [ test "works with top" <|
                \_ ->
                    "Top.elm"
                        |> Path.fromFilepath
                        |> Path.toParser
                        |> Expect.equal "Parser.map Top Parser.top"
            , test "works with single static path" <|
                \_ ->
                    "About.elm"
                        |> Path.fromFilepath
                        |> Path.toParser
                        |> Expect.equal "Parser.map About (Parser.s \"about\")"
            , test "works with multiple static paths" <|
                \_ ->
                    "About/Team.elm"
                        |> Path.fromFilepath
                        |> Path.toParser
                        |> Expect.equal "Parser.map About_Team (Parser.s \"about\" </> Parser.s \"team\")"
            , test "works with single dynamic path" <|
                \_ ->
                    "Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.toParser
                        |> Expect.equal (String.trim """
(Parser.s "posts" </> Parser.string)
  |> Parser.map (\\param1 -> { param1 = param1 })
  |> Parser.map Posts_Dynamic 
""")
            , test "works with multiple dynamic paths" <|
                \_ ->
                    "Authors/Dynamic/Posts/Dynamic.elm"
                        |> Path.fromFilepath
                        |> Path.toParser
                        |> Expect.equal (String.trim """
(Parser.s "authors" </> Parser.string </> Parser.s "posts" </> Parser.string)
  |> Parser.map (\\param1 param2 -> { param1 = param1, param2 = param2 })
  |> Parser.map Authors_Dynamic_Posts_Dynamic 
""")
            , describe "toFlags"
                [ test "works with no dynamic params" <|
                    \_ ->
                        "Top.elm"
                            |> Path.fromFilepath
                            |> Path.toFlags
                            |> Expect.equal "()"
                , test "works with one dynamic param" <|
                    \_ ->
                        "Posts/Dynamic.elm"
                            |> Path.fromFilepath
                            |> Path.toFlags
                            |> Expect.equal "{ param1 : String }"
                , test "works with multiple dynamic params" <|
                    \_ ->
                        "Authors/Dynamic/Posts/Dynamic.elm"
                            |> Path.fromFilepath
                            |> Path.toFlags
                            |> Expect.equal "{ param1 : String, param2 : String }"
                ]
            ]
        ]

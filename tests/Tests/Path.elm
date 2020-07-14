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
                        (Path.fromFilepath "Example/Id_Int.elm")
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
                    , Path.fromFilepath "Authors/Author_String/Posts/PostId_Int.elm"
                    , Path.fromFilepath "Posts/Id_Int.elm"
                    , Path.fromFilepath "Posts.elm"
                    , Path.fromFilepath "Posts/Top.elm"
                    ]
                        |> List.sortWith Path.routingOrder
                        |> Expect.equalLists
                            [ Path.fromFilepath "Top.elm"
                            , Path.fromFilepath "About.elm"
                            , Path.fromFilepath "Posts.elm"
                            , Path.fromFilepath "Posts/Top.elm"
                            , Path.fromFilepath "Posts/Id_Int.elm"
                            , Path.fromFilepath "Authors/Author_String/Posts/PostId_Int.elm"
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
                    "Authors/Author_String/Posts/PostId_Int.elm"
                        |> Path.fromFilepath
                        |> Path.toList
                        |> Expect.equalLists [ "Authors", "Author_String", "Posts", "PostId_Int" ]
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
                    "Authors/Author_String/Posts/PostId_Int.elm"
                        |> Path.fromFilepath
                        |> Path.toModulePath
                        |> Expect.equal "Authors.Author_String.Posts.PostId_Int"
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
                        |> Expect.equal "posts__top"
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Author_String/Posts/PostId_Int.elm"
                        |> Path.fromFilepath
                        |> Path.toVariableName
                        |> Expect.equal "authors__author_string__posts__postId_int"
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
                        |> Expect.equal "Posts__Top"
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Author_String/Posts/PostId_Int.elm"
                        |> Path.fromFilepath
                        |> Path.toTypeName
                        |> Expect.equal "Authors__Author_String__Posts__PostId_Int"
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
                    "Posts/Id_Int.elm"
                        |> Path.fromFilepath
                        |> Path.optionalParams
                        |> Expect.equal " { id : Int }"
            , test "works with nested folders" <|
                \_ ->
                    "Authors/Author_String/Posts/PostId_Int.elm"
                        |> Path.fromFilepath
                        |> Path.optionalParams
                        |> Expect.equal " { author : String, postId : Int }"
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
                        |> Expect.equal "Parser.map About__Team (Parser.s \"about\" </> Parser.s \"team\")"
            , test "works with single dynamic path" <|
                \_ ->
                    "Posts/Id_Int.elm"
                        |> Path.fromFilepath
                        |> Path.toParser
                        |> Expect.equal (String.trim """
(Parser.s "posts" </> Parser.int)
  |> Parser.map (\\id -> { id = id })
  |> Parser.map Posts__Id_Int
""")
            , test "works with multiple dynamic paths" <|
                \_ ->
                    "Authors/Author_String/Posts/PostId_Int.elm"
                        |> Path.fromFilepath
                        |> Path.toParser
                        |> Expect.equal (String.trim """
(Parser.s "authors" </> Parser.string </> Parser.s "posts" </> Parser.int)
  |> Parser.map (\\author postId -> { author = author, postId = postId })
  |> Parser.map Authors__Author_String__Posts__PostId_Int 
""")
            , describe "toParams"
                [ test "works with no dynamic params" <|
                    \_ ->
                        "Top.elm"
                            |> Path.fromFilepath
                            |> Path.toParams
                            |> Expect.equal "()"
                , test "works with one dynamic param" <|
                    \_ ->
                        "Posts/Id_Int.elm"
                            |> Path.fromFilepath
                            |> Path.toParams
                            |> Expect.equal "{ id : Int }"
                , test "works with multiple dynamic params" <|
                    \_ ->
                        "Authors/Author_String/Posts/PostId_Int.elm"
                            |> Path.fromFilepath
                            |> Path.toParams
                            |> Expect.equal "{ author : String, postId : Int }"
                ]
            ]
        ]

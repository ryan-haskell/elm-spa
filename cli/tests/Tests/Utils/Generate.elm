module Tests.Utils.Generate exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)
import Utils.Generate as Generate


suite : Test
suite =
    describe "Utils.Generate"
        [ describe "indent"
            [ test "indents with four spaces" <|
                \_ ->
                    "abc"
                        |> Generate.indent 1
                        |> Expect.equal "    abc"
            , test "supports indenting twice" <|
                \_ ->
                    "abc"
                        |> Generate.indent 2
                        |> Expect.equal "        abc"
            , test "works with multiple lines" <|
                \_ ->
                    "abc\ndef"
                        |> Generate.indent 1
                        |> Expect.equal "    abc\n    def"
            ]
        , describe "customType"
            [ test "returns empty string with no variants" <|
                \_ ->
                    { name = "Fruit"
                    , variants = []
                    }
                        |> Generate.customType
                        |> Expect.equal ""
            , test "returns single line for single variant" <|
                \_ ->
                    { name = "Fruit"
                    , variants = [ "Apple" ]
                    }
                        |> Generate.customType
                        |> Expect.equal "type Fruit = Apple"
            , test "returns multiple lines for multiple variants" <|
                \_ ->
                    { name = "Fruit"
                    , variants =
                        [ "Apple"
                        , "Banana"
                        , "Cherry"
                        ]
                    }
                        |> Generate.customType
                        |> Expect.equal (String.trim """
type Fruit
    = Apple
    | Banana
    | Cherry
""")
            , describe "import_"
                [ test "works with only a name" <|
                    \_ ->
                        { name = "Url"
                        , alias = Nothing
                        , exposing_ = []
                        }
                            |> Generate.import_
                            |> Expect.equal "import Url"
                , test "works with an alias" <|
                    \_ ->
                        { name = "Data.User"
                        , alias = Just "User"
                        , exposing_ = []
                        }
                            |> Generate.import_
                            |> Expect.equal "import Data.User as User"
                , test "works with a name and exposing" <|
                    \_ ->
                        { name = "Url"
                        , alias = Nothing
                        , exposing_ = [ "Url" ]
                        }
                            |> Generate.import_
                            |> Expect.equal "import Url exposing (Url)"
                , test "works with an alias and exposing" <|
                    \_ ->
                        { name = "Data.User"
                        , alias = Just "User"
                        , exposing_ = [ "User" ]
                        }
                            |> Generate.import_
                            |> Expect.equal "import Data.User as User exposing (User)"
                , test "works with an alias and mutiple exposing items" <|
                    \_ ->
                        { name = "Css.Html"
                        , alias = Just "Html"
                        , exposing_ = [ "Html", "div" ]
                        }
                            |> Generate.import_
                            |> Expect.equal "import Css.Html as Html exposing (Html, div)"
                ]
            , describe "recordType"
                [ test "has empty record when given no properties" <|
                    \_ ->
                        []
                            |> Generate.recordType
                            |> Expect.equal "{}"
                , test "has single-line record when given one property" <|
                    \_ ->
                        [ ( "name", "String" ) ]
                            |> Generate.recordType
                            |> Expect.equal "{ name : String }"
                , test "has multi-line record when given multiple property" <|
                    \_ ->
                        [ ( "name", "String" )
                        , ( "age", "Int" )
                        ]
                            |> Generate.recordType
                            |> Expect.equal (String.trim """
{ name : String
, age : Int
}
""")
                ]
            , describe "recordValue"
                [ test "has empty record when given no properties" <|
                    \_ ->
                        []
                            |> Generate.recordValue
                            |> Expect.equal "{}"
                , test "has single-line record when given one property" <|
                    \_ ->
                        [ ( "name", "\"Ryan\"" ) ]
                            |> Generate.recordValue
                            |> Expect.equal "{ name = \"Ryan\" }"
                , test "has multi-line record when given multiple property" <|
                    \_ ->
                        [ ( "name", "\"Ryan\"" )
                        , ( "age", "123" )
                        ]
                            |> Generate.recordValue
                            |> Expect.equal (String.trim """
{ name = "Ryan"
, age = 123
}
""")
                ]
            , describe "tuple"
                [ test "has empty tuple when given no properties" <|
                    \_ ->
                        []
                            |> Generate.tuple
                            |> Expect.equal "()"
                , test "has single-line tuple when given one property" <|
                    \_ ->
                        [ "123" ]
                            |> Generate.tuple
                            |> Expect.equal "( 123 )"
                , test "has multi-line tuple when given multiple property" <|
                    \_ ->
                        [ "123"
                        , "456"
                        ]
                            |> Generate.tuple
                            |> Expect.equal (String.trim """
( 123
, 456
)
""")
                ]
            , describe "list"
                [ test "has empty list when given no properties" <|
                    \_ ->
                        []
                            |> Generate.list
                            |> Expect.equal "[]"
                , test "has single-line list when given one property" <|
                    \_ ->
                        [ "123" ]
                            |> Generate.list
                            |> Expect.equal "[ 123 ]"
                , test "has multi-line list when given multiple property" <|
                    \_ ->
                        [ "123"
                        , "456"
                        ]
                            |> Generate.list
                            |> Expect.equal (String.trim """
[ 123
, 456
]
""")
                ]
            , describe "function"
                [ test "returns blank string without annotation" <|
                    \_ ->
                        { name = "name"
                        , annotation = []
                        , inputs = []
                        , body = "\"Ryan\""
                        }
                            |> Generate.function
                            |> Expect.equal ""
                , test "works with no inputs" <|
                    \_ ->
                        { name = "name"
                        , annotation = [ "String" ]
                        , inputs = []
                        , body = "\"Ryan\""
                        }
                            |> Generate.function
                            |> Expect.equal (String.trim """
name : String
name =
    "Ryan"
""")
                , test "works with one input" <|
                    \_ ->
                        { name = "length"
                        , annotation = [ "String", "Int" ]
                        , inputs = [ "name" ]
                        , body = "String.length name"
                        }
                            |> Generate.function
                            |> Expect.equal (String.trim """
length : String -> Int
length name =
    String.length name
""")
                , test "works with multiple input" <|
                    \_ ->
                        { name = "fullname"
                        , annotation = [ "String", "String", "String" ]
                        , inputs = [ "first", "last" ]
                        , body = "first ++ \" \" ++ last"
                        }
                            |> Generate.function
                            |> Expect.equal (String.trim """
fullname : String -> String -> String
fullname first last =
    first ++ " " ++ last
""")
                ]
            , describe "caseExpression"
                [ test "returns empty string with missing conditionals" <|
                    \_ ->
                        { variable = "route"
                        , cases = []
                        }
                            |> Generate.caseExpression
                            |> Expect.equal ""
                , test "works with multiple conditions" <|
                    \_ ->
                        { variable = "route"
                        , cases =
                            [ ( "Top", "\"/\"" )
                            , ( "About", "\"/about\"" )
                            , ( "NotFound", "\"/not-found\"" )
                            ]
                        }
                            |> Generate.caseExpression
                            |> Expect.equal (String.trim """
case route of
    Top ->
        "/"
    
    About ->
        "/about"
    
    NotFound ->
        "/not-found"
""")
                ]
            ]
        ]

module UnitTests.Utils.StringTest exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import Utils.String


suite : Test
suite =
    describe "Utils.String"
        [ describe "capitalizeFirstLetter"
            [ test "works with a single word"
                (\_ ->
                    Utils.String.capitalizeFirstLetter "ryan"
                        |> Expect.equal "Ryan"
                )
            , test "doesn't affect already capitalized words"
                (\_ ->
                    Utils.String.capitalizeFirstLetter "Ryan"
                        |> Expect.equal "Ryan"
                )
            , test "only capitalizes first word in sentence"
                (\_ ->
                    Utils.String.capitalizeFirstLetter "ryan loves writing unit tests"
                        |> Expect.equal "Ryan loves writing unit tests"
                )
            ]
        ]

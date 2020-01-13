module UtilsTest exposing (expected, input, suite)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Set exposing (Set)
import Test exposing (..)
import Utils exposing (Items)


suite : Test
suite =
    describe "Utils"
        [ describe "allSubsets"
            [ test "works with authors posts example" <|
                \_ ->
                    Utils.allSubsets
                        [ [ "Top" ]
                        , [ "NotFound" ]
                        , [ "Authors", "Dynamic", "Posts", "Dynamic" ]
                        ]
                        |> Expect.equalLists
                            [ [ "Top" ]
                            , [ "NotFound" ]
                            , [ "Authors" ]
                            , [ "Authors", "Dynamic" ]
                            , [ "Authors", "Dynamic", "Posts" ]
                            , [ "Authors", "Dynamic", "Posts", "Dynamic" ]
                            ]
            ]
        , describe "addInMissingFolders"
            [ test "works with authors post example" <|
                \_ ->
                    Utils.addInMissingFolders input
                        |> Expect.equalDicts expected
            ]
        ]


input : Dict String Items
input =
    Dict.fromList
        [ ( ""
          , { files = Set.fromList [ [ "NotFound" ], [ "Top" ] ]
            , folders = Set.fromList []
            }
          )
        , ( "Authors.Dynamic"
          , { files = Set.fromList []
            , folders = Set.fromList [ [ "Authors", "Dynamic", "Posts" ] ]
            }
          )
        , ( "Authors.Dynamic.Posts"
          , { files = Set.fromList [ [ "Authors", "Dynamic", "Posts", "Dynamic" ] ]
            , folders = Set.fromList []
            }
          )
        ]


expected : Dict String Items
expected =
    Dict.fromList
        [ ( ""
          , { files = Set.fromList [ [ "NotFound" ], [ "Top" ] ]
            , folders = Set.fromList [ [ "Authors" ] ]
            }
          )
        , ( "Authors"
          , { files = Set.fromList []
            , folders = Set.fromList [ [ "Authors", "Dynamic" ] ]
            }
          )
        , ( "Authors.Dynamic"
          , { files = Set.fromList []
            , folders = Set.fromList [ [ "Authors", "Dynamic", "Posts" ] ]
            }
          )
        , ( "Authors.Dynamic.Posts"
          , { files = Set.fromList [ [ "Authors", "Dynamic", "Posts", "Dynamic" ] ]
            , folders = Set.fromList []
            }
          )
        ]

module ProgramTests.Homepage exposing (all)

import Pages.Home_
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


start : ProgramTest Pages.Home_.Model Pages.Home_.Msg (Cmd Pages.Home_.Msg)
start =
    ProgramTest.createDocument
        { init = \_ -> Pages.Home_.init
        , update = Pages.Home_.update
        , view = Pages.Home_.view
        }
        |> ProgramTest.start ()


all : Test
all =
    describe "Pages.Homepage_"
        [ test "Counter increment works" <|
            \() ->
                start
                    |> clickButton "+"
                    |> expectViewHas
                        [ text "Count: 1"
                        ]
        , test "Counter decrement works" <|
            \() ->
                start
                    |> clickButton "-"
                    |> expectViewHas
                        [ text "Count: -1"
                        ]
        , test "Clicking multiple buttons works too" <|
            \() ->
                start
                    |> clickButton "-"
                    |> clickButton "+"
                    |> clickButton "-"
                    |> clickButton "-"
                    |> expectViewHas
                        [ text "Count: -2"
                        ]
        ]

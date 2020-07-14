module Program.TopTest exposing (all)

import Pages.Top as Page
import ProgramTest exposing (ProgramTest, expectViewHas)
import Program.Utils.Spa
import Test exposing (..)
import Test.Html.Selector exposing (text)


start : ProgramTest Page.Model Page.Msg (Cmd Page.Msg)
start =
    Program.Utils.Spa.createStaticPage
        { view = Page.view
        }


all : Test
all =
    describe "Pages.Top"
        [ test "should say homepage" <|
            \() ->
                start
                    |> expectViewHas [ text "Homepage" ]
        ]

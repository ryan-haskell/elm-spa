module Program.NotFoundTest exposing (all)

import Pages.NotFound as Page
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
    describe "Pages.NotFound"
        [ test "should say page not found" <|
            \() ->
                start
                    |> expectViewHas [ text "Page not found" ]
        ]

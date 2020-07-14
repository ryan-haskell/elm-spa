module Program.Utils.Spa exposing
    ( createElementPage
    , createSandboxPage
    , createStaticPage
    )

import ProgramTest exposing (ProgramTest)
import Spa.Document exposing (Document)
import Spa.Url exposing (Url)


createStaticPage :
    { view : Document msg
    }
    -> ProgramTest () msg (Cmd msg)
createStaticPage page =
    ProgramTest.createDocument
        { init = \_ -> ( (), Cmd.none )
        , update = \_ model -> ( model, Cmd.none )
        , view = \_ -> page.view |> Spa.Document.toBrowserDocument
        }
        |> ProgramTest.start ()


createSandboxPage :
    { init : model
    , update : msg -> model -> model
    , view : model -> Document msg
    }
    -> ProgramTest model msg (Cmd msg)
createSandboxPage page =
    ProgramTest.createDocument
        { init = \_ -> ( page.init, Cmd.none )
        , update = \msg model -> ( page.update msg model, Cmd.none )
        , view = page.view >> Spa.Document.toBrowserDocument
        }
        |> ProgramTest.start ()


createElementPage :
    Url params
    ->
        { init : Url params -> ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , view : model -> Document msg
        }
    -> ProgramTest model msg (Cmd msg)
createElementPage params page =
    ProgramTest.createDocument
        { init = page.init
        , update = page.update
        , view = page.view >> Spa.Document.toBrowserDocument
        }
        |> ProgramTest.start params

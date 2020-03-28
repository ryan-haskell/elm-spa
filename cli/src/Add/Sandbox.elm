module Add.Sandbox exposing (create)

import Path exposing (Path)


create : Path -> String
create path =
    """
module Pages.{{name}} exposing (Flags, Model, Msg, page)

import Html
import Page exposing (Document, Page)


type alias Flags =
    {{flags}}


type alias Model =
    {}


type Msg
    = NoOp


page : Page Flags Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }


init : Model
init =
    {}


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            {}


view : Model -> Document Msg
view model =
    { title = "{{name}}"
    , body = [ Html.text "{{name}}" ]
    }
"""
        |> String.replace "{{name}}" (Path.toModulePath path)
        |> String.replace "{{flags}}" (Path.toFlags path)
        |> String.trim

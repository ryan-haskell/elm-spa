module Add.Sandbox exposing (create)

import Path exposing (Path)


create : Path -> String
create path =
    """
module Pages.{{name}} exposing (Flags, Model, Msg, page)

import Browser exposing (Document)
import Global
import Html
import Spa


type alias Flags =
    {{flags}}


type alias Model =
    {}


type Msg
    = NoOp


page : Spa.Page Flags Model Msg Global.Model Global.Msg
page =
    Spa.sandbox
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

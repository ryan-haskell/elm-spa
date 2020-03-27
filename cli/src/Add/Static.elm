module Add.Static exposing (create)

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
    ()


type alias Msg =
    Never


page : Spa.Page Flags Model Msg Global.Model Global.Msg
page =
    Spa.static
        { view = view
        }


view : Document Msg
view =
    { title = "{{name}}"
    , body = [ Html.text "{{name}}" ]
    }
"""
        |> String.replace "{{name}}" (Path.toModulePath path)
        |> String.replace "{{flags}}" (Path.toFlags path)
        |> String.trim

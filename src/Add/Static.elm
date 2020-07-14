module Add.Static exposing (create)

import Path exposing (Path)


create : Path -> String
create path =
    """
module Pages.{{name}} exposing (Params, Model, Msg, page)

import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }


type alias Model =
    Url Params


type alias Msg =
    Never



-- VIEW


type alias Params =
    {{params}}


view : Url Params -> Document Msg
view { params } =
    { title = "{{name}}"
    , body = []
    }
"""
        |> String.replace "{{name}}" (Path.toModulePath path)
        |> String.replace "{{params}}" (Path.toParams path)
        |> String.trim

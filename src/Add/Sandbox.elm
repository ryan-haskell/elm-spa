module Add.Sandbox exposing (create)

import Path exposing (Path)


create : Path -> String
create path =
    """
module Pages.{{name}} exposing (Model, Msg, Params, page)

import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import UI exposing (Components)
import UI.Content exposing (Type(..))


page : Page Params Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Params =
    {{params}}


type alias Model =
    {}


init : Url Params -> Model
init { params } =
    {}



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> Model
update msg model =
    case msg of
        ReplaceMe ->
            {}



-- VIEW


view : Components Msg -> Model -> Document Msg
view { t } model =
    { title = "{{name}}"
    , body = t Static "{{name}}"
    }
"""
        |> String.replace "{{name}}" (Path.toModulePath path)
        |> String.replace "{{params}}" (Path.toParams path)
        |> String.trim

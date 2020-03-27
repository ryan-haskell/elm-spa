module Add.Component exposing (create)

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
    Spa.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global flags =
    ( {}, Cmd.none, Cmd.none )


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update global msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none, Cmd.none )


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions global model =
    Sub.none


view : Global.Model -> Model -> Document Msg
view global model =
    { title = "{{name}}"
    , body = [ Html.text "{{name}}" ]
    }
"""
        |> String.replace "{{name}}" (Path.toModulePath path)
        |> String.replace "{{flags}}" (Path.toFlags path)
        |> String.trim

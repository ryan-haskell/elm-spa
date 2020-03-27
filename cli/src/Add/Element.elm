module Add.Element exposing (create)

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
    Spa.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Document Msg
view model =
    { title = "{{name}}"
    , body = [ Html.text "{{name}}" ]
    }
"""
        |> String.replace "{{name}}" (Path.toModulePath path)
        |> String.replace "{{flags}}" (Path.toFlags path)
        |> String.trim

module Add.Element exposing (create)

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
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Params =
    {{params}}


type alias Model =
    {}


init : Url Params -> ( Model, Cmd Msg )
init { params } =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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

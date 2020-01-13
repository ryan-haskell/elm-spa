module Templates.Sandbox exposing (contents)


contents : { modulePath : List String, ui : String } -> String
contents options =
    """
module Pages.{{moduleName}} exposing (Model, Msg, page)

import Spa.Page
import {{ui}} exposing (..)
import Generated{{moduleFolder}}.Params as Params
import Utils.Spa exposing (Page)


page : Page Params.{{fileName}} Model Msg model msg appMsg
page =
    Spa.Page.sandbox
        { title = always "{{moduleName}}"
        , init = always init
        , update = always update
        , view = always view
        }



-- INIT


type alias Model =
    {}


init : Params.{{fileName}} -> Model
init _ =
    {}



-- UPDATE


type Msg
    = Msg


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> {{ui}} Msg
view model =
    text "{{moduleName}}"

    """
        |> String.replace "{{moduleName}}" (String.join "." options.modulePath)
        |> String.replace "{{fileName}}" (options.modulePath |> List.reverse |> List.head |> Maybe.withDefault "YellAtRyanOnTheInternet")
        |> String.replace "{{moduleFolder}}" (options.modulePath |> List.reverse |> List.drop 1 |> List.reverse |> List.map (String.append ".") |> String.concat)
        |> String.replace "{{ui}}" options.ui
        |> String.trim

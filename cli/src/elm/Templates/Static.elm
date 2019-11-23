module Templates.Static exposing (contents)


contents : { modulePath : List String, ui : String } -> String
contents options =
    """
module Pages.{{moduleName}} exposing (Model, Msg, page)

import Spa.Page
import {{ui}} exposing (..)
import Generated{{moduleFolder}}.Params as Params
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.{{fileName}} Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "{{moduleName}}"
        , view = always view
        }



-- VIEW


view : {{ui}} Msg
view =
    text "{{moduleName}}"

    """
        |> String.replace "{{moduleName}}" (String.join "." options.modulePath)
        |> String.replace "{{fileName}}" (options.modulePath |> List.reverse |> List.head |> Maybe.withDefault "YellAtRyanOnTheInternet")
        |> String.replace "{{moduleFolder}}" (options.modulePath |> List.reverse |> List.drop 1 |> List.reverse |> List.map (String.append ".") |> String.concat)
        |> String.replace "{{ui}}" options.ui
        |> String.trim

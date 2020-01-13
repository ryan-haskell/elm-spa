module Templates.Component exposing (contents)


contents : { modulePath : List String, ui : String } -> String
contents options =
    """
module Pages.{{moduleName}} exposing (Model, Msg, page)

import Spa.Page
import {{ui}} exposing (..)
import Generated{{moduleFolder}}.Params as Params
import Global
import Utils.Spa exposing (Page)


page : Page Params.{{fileName}} Model Msg model msg appMsg
page =
    Spa.Page.component
        { title = always "{{moduleName}}"
        , init = always init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }



-- INIT


type alias Model =
    {}


init : Params.{{fileName}} -> ( Model, Cmd Msg, Cmd Global.Msg )
init _ =
    ( {}
    , Cmd.none
    , Cmd.none
    )



-- UPDATE


type Msg
    = Msg


update : Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update msg model =
    ( model
    , Cmd.none
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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

import {
  pagesImports, paramsImports,
  pagesBundleAnnotation,
  pagesBundleDefinition,
  pagesInitBody,
  pagesSubscriptionsBody,
  pagesViewBody,
  pagesUpdateBody,
  pagesUpdateCatchAll,
  Options
} from "./utils"

export default (pages : string[][], options : Options) : string => `
module Gen.Pages exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Request exposing (Request)
${paramsImports(pages)}
import Gen.Model as Model
import Gen.Msg as Msg
import Gen.Route as Route exposing (Route)
import Page exposing (Page)
${pagesImports(pages)}
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


type alias Model =
    Model.Model


type alias Msg =
    Msg.Msg


init : Route -> Shared.Model -> Url -> Key -> ( Model, Cmd Msg, Cmd Shared.Msg )
init route =
${pagesInitBody(pages)}


update : Msg -> Model -> Shared.Model -> Url -> Key -> ( Model, Cmd Msg, Cmd Shared.Msg )
update msg_ model_ =
${pagesUpdateBody(pages.filter(page => options.isStatic(page) === false), options)}
${pages.length > 1 ? pagesUpdateCatchAll : ''}


view : Model -> Shared.Model -> Url -> Key -> View Msg
view model_ =
${pagesViewBody(pages, options)}


subscriptions : Model -> Shared.Model -> Url -> Key -> Sub Msg
subscriptions model_ =
${pagesSubscriptionsBody(pages, options)}



-- INTERNALS


pages :
${pagesBundleAnnotation(pages, options)}
pages =
${pagesBundleDefinition(pages, options)}


type alias Bundle params model msg =
    { init : params -> Shared.Model -> Url -> Key -> ( Model, Cmd Msg, Cmd Shared.Msg )
    , update : params -> msg -> model -> Shared.Model -> Url -> Key -> ( Model, Cmd Msg, Cmd Shared.Msg )
    , view : params -> model -> Shared.Model -> Url -> Key -> View Msg
    , subscriptions : params -> model -> Shared.Model -> Url -> Key -> Sub Msg
    }


bundle :
    (Shared.Model -> Request params -> Page model msg)
    -> (params -> model -> Model)
    -> (msg -> Msg)
    -> Bundle params model msg
bundle page toModel toMsg =
    let
        mapTriple :
            params
            -> ( model, Cmd msg, List Shared.Msg )
            -> ( Model, Cmd Msg, Cmd Shared.Msg )
        mapTriple params ( model, cmd, sharedMsgList ) =
            ( toModel params model
            , Cmd.map toMsg cmd
            , sharedMsgList
                |> List.map (Task.succeed >> Task.perform identity)
                |> Cmd.batch
            )
    in
    { init =
        \\params shared url key ->
            (page shared (Request.create params url key)).init ()
                |> mapTriple params
    , update =
        \\params msg model shared url key ->
            (page shared (Request.create params url key)).update msg model
                |> mapTriple params
    , view =
        \\params model shared url key ->
            (page shared (Request.create params url key)).view model
                |> View.map toMsg
    , subscriptions =
        \\params model shared url key ->
            (page shared (Request.create params url key)).subscriptions model
                |> Sub.map toMsg
    }


type alias Static params =
    Bundle params () Never


static : View Never -> (params -> Model) -> Static params
static view_ toModel =
    { init = \\params _ _ _ -> ( toModel params, Cmd.none, Cmd.none )
    , update = \\params _ _ _ _ _ -> ( toModel params, Cmd.none, Cmd.none )
    , view = \\_ _ _ _ _ -> View.map never view_
    , subscriptions = \\_ _ _ _ _ -> Sub.none
    }
    
`.trimLeft()

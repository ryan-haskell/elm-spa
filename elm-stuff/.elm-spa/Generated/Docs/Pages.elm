module Generated.Docs.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Docs.Params as Params
import Generated.Docs.Route as Route exposing (Route(..))
import Layouts.Docs as Layout
import Pages.Docs.Dynamic
import Pages.Docs.Static
import Utils.Page as Page exposing (Page)


type Model
    = DynamicModel Pages.Docs.Dynamic.Model
    | StaticModel Pages.Docs.Static.Model


type Msg
    = DynamicMsg Pages.Docs.Dynamic.Msg
    | StaticMsg Pages.Docs.Static.Msg


page : Page Route Model Msg layoutModel layoutMsg appMsg
page =
    Page.layout
        { view = Layout.view
        , recipe =
            { init = init
            , update = update
            , bundle = bundle
            }
        }



-- RECIPES


type alias Recipe flags model msg appMsg =
    Page.Recipe flags model msg Model Msg appMsg


type alias Recipes msg =
    { dynamic : Recipe Params.Dynamic Pages.Docs.Dynamic.Model Pages.Docs.Dynamic.Msg msg
    , static : Recipe Params.Static Pages.Docs.Static.Model Pages.Docs.Static.Msg msg
    }


recipes : Recipes msg
recipes =
    { dynamic =
        Page.recipe
            { page = Pages.Docs.Dynamic.page
            , toModel = DynamicModel
            , toMsg = DynamicMsg
            }
    , static =
        Page.recipe
            { page = Pages.Docs.Static.page
            , toModel = StaticModel
            , toMsg = StaticMsg
            }
    }



-- INIT


init : Route -> Page.Init Model Msg
init route =
    case route of
        Route.Dynamic _ flags ->
            recipes.dynamic.init flags

        Route.Static flags ->
            recipes.static.init flags



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( DynamicMsg msg, DynamicModel model ) ->
            recipes.dynamic.update msg model

        ( StaticMsg msg, StaticModel model ) ->
            recipes.static.update msg model

        _ ->
            App.Page.keep bigModel



-- BUNDLE


bundle : Model -> Page.Bundle Msg msg
bundle bigModel =
    case bigModel of
        DynamicModel model ->
            recipes.dynamic.bundle model

        StaticModel model ->
            recipes.static.bundle model

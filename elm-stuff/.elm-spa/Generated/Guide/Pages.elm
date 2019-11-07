module Generated.Guide.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Guide.Dynamic.Pages
import Generated.Guide.Dynamic.Route
import Generated.Guide.Params as Params
import Generated.Guide.Route as Route exposing (Route)
import Layouts.Guide as Layout
import Pages.Guide.Elm
import Pages.Guide.ElmSpa
import Pages.Guide.Programming
import Utils.Page as Page exposing (Page)


type Model
    = ElmModel Pages.Guide.Elm.Model
    | ElmSpaModel Pages.Guide.ElmSpa.Model
    | ProgrammingModel Pages.Guide.Programming.Model
    | Dynamic_Folder_Model Generated.Guide.Dynamic.Pages.Model


type Msg
    = ElmMsg Pages.Guide.Elm.Msg
    | ElmSpaMsg Pages.Guide.ElmSpa.Msg
    | ProgrammingMsg Pages.Guide.Programming.Msg
    | Dynamic_Folder_Msg Generated.Guide.Dynamic.Pages.Msg


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
    { elm : Recipe Params.Elm Pages.Guide.Elm.Model Pages.Guide.Elm.Msg msg
    , elmApp : Recipe Params.ElmSpa Pages.Guide.ElmSpa.Model Pages.Guide.ElmSpa.Msg msg
    , programming : Recipe Params.Programming Pages.Guide.Programming.Model Pages.Guide.Programming.Msg msg
    , dynamic_folder : Recipe Generated.Guide.Dynamic.Route.Route Generated.Guide.Dynamic.Pages.Model Generated.Guide.Dynamic.Pages.Msg msg
    }


recipes : Recipes msg
recipes =
    { elm =
        Page.recipe
            { page = Pages.Guide.Elm.page
            , toModel = ElmModel
            , toMsg = ElmMsg
            }
    , elmApp =
        Page.recipe
            { page = Pages.Guide.ElmSpa.page
            , toModel = ElmSpaModel
            , toMsg = ElmSpaMsg
            }
    , programming =
        Page.recipe
            { page = Pages.Guide.Programming.page
            , toModel = ProgrammingModel
            , toMsg = ProgrammingMsg
            }
    , dynamic_folder =
        Page.recipe
            { page = Generated.Guide.Dynamic.Pages.page
            , toModel = Dynamic_Folder_Model
            , toMsg = Dynamic_Folder_Msg
            }
    }



-- INIT


init : Route -> Page.Init Model Msg
init route =
    case route of
        Route.Elm flags ->
            recipes.elm.init flags

        Route.ElmSpa flags ->
            recipes.elmApp.init flags

        Route.Programming flags ->
            recipes.programming.init flags

        Route.Dynamic_Folder flags route_ ->
            recipes.dynamic_folder.init route_



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( ElmMsg msg, ElmModel model ) ->
            recipes.elm.update msg model

        ( ElmSpaMsg msg, ElmSpaModel model ) ->
            recipes.elmApp.update msg model

        ( ProgrammingMsg msg, ProgrammingModel model ) ->
            recipes.programming.update msg model

        ( Dynamic_Folder_Msg msg, Dynamic_Folder_Model model ) ->
            recipes.dynamic_folder.update msg model

        _ ->
            App.Page.keep bigModel



-- BUNDLE


bundle : Model -> Page.Bundle Msg msg
bundle bigModel =
    case bigModel of
        ElmModel model ->
            recipes.elm.bundle model

        ElmSpaModel model ->
            recipes.elmApp.bundle model

        ProgrammingModel model ->
            recipes.programming.bundle model

        Dynamic_Folder_Model model ->
            recipes.dynamic_folder.bundle model

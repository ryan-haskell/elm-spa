module Generated.Guide.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import App.Pattern exposing (static, dynamic)
import Layouts.Guide as Layout
import Utils.Spa as Spa
import Generated.Guide.Params as Params
import Generated.Guide.Route as Route exposing (Route)
import Pages.Guide.Elm
import Pages.Guide.ElmSpa
import Pages.Guide.Programming
import Generated.Guide.Dynamic.Route
import Generated.Guide.Dynamic.Pages


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


page : Spa.Page Route Model Msg layoutModel layoutMsg appMsg
page =
    Spa.layout
        { pattern = [ static "guide" ]
        , transition = Layout.transition
        , view = Layout.view
        , recipe =
            { init = init
            , update = update
            , bundle = bundle
            }
        }



-- RECIPES


type alias Recipe flags model msg appMsg =
    Spa.Recipe flags model msg Model Msg appMsg


type alias Recipes msg =
    { elm : Recipe Params.Elm Pages.Guide.Elm.Model Pages.Guide.Elm.Msg msg
    , elmSpa : Recipe Params.ElmSpa Pages.Guide.ElmSpa.Model Pages.Guide.ElmSpa.Msg msg
    , programming : Recipe Params.Programming Pages.Guide.Programming.Model Pages.Guide.Programming.Msg msg
    , dynamic_folder : Recipe Generated.Guide.Dynamic.Route.Route Generated.Guide.Dynamic.Pages.Model Generated.Guide.Dynamic.Pages.Msg msg
    }


recipes : Recipes msg
recipes =
    { elm =
        Spa.recipe
            { page = Pages.Guide.Elm.page
            , toModel = ElmModel
            , toMsg = ElmMsg
            }
    , elmSpa =
        Spa.recipe
            { page = Pages.Guide.ElmSpa.page
            , toModel = ElmSpaModel
            , toMsg = ElmSpaMsg
            }
    , programming =
        Spa.recipe
            { page = Pages.Guide.Programming.page
            , toModel = ProgrammingModel
            , toMsg = ProgrammingMsg
            }
    , dynamic_folder =
        Spa.recipe
            { page = Generated.Guide.Dynamic.Pages.page
            , toModel = Dynamic_Folder_Model
            , toMsg = Dynamic_Folder_Msg
            }
    }



-- INIT


init : Route -> Spa.Init Model Msg
init route_ =
    case route_ of
        Route.Elm params ->
            recipes.elm.init params
        
        Route.ElmSpa params ->
            recipes.elmSpa.init params
        
        Route.Programming params ->
            recipes.programming.init params
        
        Route.Dynamic_Folder _ route ->
            recipes.dynamic_folder.init route



-- UPDATE


update : Msg -> Model -> Spa.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( ElmMsg msg, ElmModel model ) ->
            recipes.elm.update msg model
        
        ( ElmSpaMsg msg, ElmSpaModel model ) ->
            recipes.elmSpa.update msg model
        
        ( ProgrammingMsg msg, ProgrammingModel model ) ->
            recipes.programming.update msg model
        
        ( Dynamic_Folder_Msg msg, Dynamic_Folder_Model model ) ->
            recipes.dynamic_folder.update msg model
        _ ->
            App.Page.keep bigModel


-- BUNDLE


bundle : Model -> Spa.Bundle Msg msg
bundle bigModel =
    case bigModel of
        ElmModel model ->
            recipes.elm.bundle model
        
        ElmSpaModel model ->
            recipes.elmSpa.bundle model
        
        ProgrammingModel model ->
            recipes.programming.bundle model
        
        Dynamic_Folder_Model model ->
            recipes.dynamic_folder.bundle model
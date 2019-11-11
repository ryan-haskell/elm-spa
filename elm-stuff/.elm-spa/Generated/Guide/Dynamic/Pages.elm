module Generated.Guide.Dynamic.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Guide.Dynamic.Dynamic.Pages
import Generated.Guide.Dynamic.Dynamic.Route
import Generated.Guide.Dynamic.Faq.Pages
import Generated.Guide.Dynamic.Faq.Route
import Generated.Guide.Dynamic.Params as Params
import Generated.Guide.Dynamic.Route as Route exposing (Route)
import Layouts.Guide.Dynamic as Layout
import Pages.Guide.Dynamic.Dynamic
import Pages.Guide.Dynamic.Intro
import Pages.Guide.Dynamic.Other
import Utils.Page as Page exposing (Page)


type Model
    = IntroModel Pages.Guide.Dynamic.Intro.Model
    | OtherModel Pages.Guide.Dynamic.Other.Model
    | DynamicModel Pages.Guide.Dynamic.Dynamic.Model
    | Faq_FolderModel Generated.Guide.Dynamic.Faq.Pages.Model
    | Dynamic_FolderModel Generated.Guide.Dynamic.Dynamic.Pages.Model


type Msg
    = IntroMsg Pages.Guide.Dynamic.Intro.Msg
    | OtherMsg Pages.Guide.Dynamic.Other.Msg
    | DynamicMsg Pages.Guide.Dynamic.Dynamic.Msg
    | Faq_FolderMsg Generated.Guide.Dynamic.Faq.Pages.Msg
    | Dynamic_FolderMsg Generated.Guide.Dynamic.Dynamic.Pages.Msg


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
    { intro : Recipe Params.Intro Pages.Guide.Dynamic.Intro.Model Pages.Guide.Dynamic.Intro.Msg msg
    , other : Recipe Params.Other Pages.Guide.Dynamic.Other.Model Pages.Guide.Dynamic.Other.Msg msg
    , dynamic : Recipe Params.Dynamic Pages.Guide.Dynamic.Dynamic.Model Pages.Guide.Dynamic.Dynamic.Msg msg
    , faq_folder : Recipe Generated.Guide.Dynamic.Faq.Route.Route Generated.Guide.Dynamic.Faq.Pages.Model Generated.Guide.Dynamic.Faq.Pages.Msg msg
    , dynamic_folder : Recipe Generated.Guide.Dynamic.Dynamic.Route.Route Generated.Guide.Dynamic.Dynamic.Pages.Model Generated.Guide.Dynamic.Dynamic.Pages.Msg msg
    }


recipes : Recipes msg
recipes =
    { intro =
        Page.recipe
            { page = Pages.Guide.Dynamic.Intro.page
            , toModel = IntroModel
            , toMsg = IntroMsg
            }
    , other =
        Page.recipe
            { page = Pages.Guide.Dynamic.Other.page
            , toModel = OtherModel
            , toMsg = OtherMsg
            }
    , dynamic =
        Page.recipe
            { page = Pages.Guide.Dynamic.Dynamic.page
            , toModel = DynamicModel
            , toMsg = DynamicMsg
            }
    , faq_folder =
        Page.recipe
            { page = Generated.Guide.Dynamic.Faq.Pages.page
            , toModel = Faq_FolderModel
            , toMsg = Faq_FolderMsg
            }
    , dynamic_folder =
        Page.recipe
            { page = Generated.Guide.Dynamic.Dynamic.Pages.page
            , toModel = Dynamic_FolderModel
            , toMsg = Dynamic_FolderMsg
            }
    }



-- INIT


init : Route -> Page.Init Model Msg
init route =
    case route of
        Route.Intro flags ->
            recipes.intro.init flags

        Route.Other flags ->
            recipes.other.init flags

        Route.Dynamic _ flags ->
            recipes.dynamic.init flags

        Route.Faq_Folder flags ->
            recipes.faq_folder.init flags

        Route.Dynamic_Folder _ flags ->
            recipes.dynamic_folder.init flags



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( IntroMsg msg, IntroModel model ) ->
            recipes.intro.update msg model

        ( OtherMsg msg, OtherModel model ) ->
            recipes.other.update msg model

        ( DynamicMsg msg, DynamicModel model ) ->
            recipes.dynamic.update msg model

        ( Faq_FolderMsg msg, Faq_FolderModel model ) ->
            recipes.faq_folder.update msg model

        ( Dynamic_FolderMsg msg, Dynamic_FolderModel model ) ->
            recipes.dynamic_folder.update msg model

        _ ->
            App.Page.keep bigModel



-- BUNDLE


bundle : Model -> Page.Bundle Msg msg
bundle bigModel =
    case bigModel of
        IntroModel model ->
            recipes.intro.bundle model

        OtherModel model ->
            recipes.other.bundle model

        DynamicModel model ->
            recipes.dynamic.bundle model

        Faq_FolderModel model ->
            recipes.faq_folder.bundle model

        Dynamic_FolderModel model ->
            recipes.dynamic_folder.bundle model

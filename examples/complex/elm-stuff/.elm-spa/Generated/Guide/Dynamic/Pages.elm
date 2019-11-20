module Generated.Guide.Dynamic.Pages exposing
    ( Model
    , Msg
    , page
    )

import Spa.Page
import Spa.Pattern exposing (static, dynamic)
import Layouts.Guide.Dynamic as Layout
import Utils.Spa as Spa
import Generated.Guide.Dynamic.Params as Params
import Generated.Guide.Dynamic.Route as Route exposing (Route)
import Pages.Guide.Dynamic.Intro
import Pages.Guide.Dynamic.Other
import Generated.Guide.Dynamic.Dynamic.Route
import Generated.Guide.Dynamic.Faq.Route
import Generated.Guide.Dynamic.Dynamic.Pages
import Generated.Guide.Dynamic.Faq.Pages


type Model
    = IntroModel Pages.Guide.Dynamic.Intro.Model
    | OtherModel Pages.Guide.Dynamic.Other.Model
    | Dynamic_Folder_Model Generated.Guide.Dynamic.Dynamic.Pages.Model
    | Faq_Folder_Model Generated.Guide.Dynamic.Faq.Pages.Model


type Msg
    = IntroMsg Pages.Guide.Dynamic.Intro.Msg
    | OtherMsg Pages.Guide.Dynamic.Other.Msg
    | Dynamic_Folder_Msg Generated.Guide.Dynamic.Dynamic.Pages.Msg
    | Faq_Folder_Msg Generated.Guide.Dynamic.Faq.Pages.Msg


page : Spa.Page Route Model Msg layoutModel layoutMsg appMsg
page =
    Spa.layout
        { pattern = [ static "guide", dynamic ]
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
    { intro : Recipe Params.Intro Pages.Guide.Dynamic.Intro.Model Pages.Guide.Dynamic.Intro.Msg msg
    , other : Recipe Params.Other Pages.Guide.Dynamic.Other.Model Pages.Guide.Dynamic.Other.Msg msg
    , dynamic_folder : Recipe Generated.Guide.Dynamic.Dynamic.Route.Route Generated.Guide.Dynamic.Dynamic.Pages.Model Generated.Guide.Dynamic.Dynamic.Pages.Msg msg
    , faq_folder : Recipe Generated.Guide.Dynamic.Faq.Route.Route Generated.Guide.Dynamic.Faq.Pages.Model Generated.Guide.Dynamic.Faq.Pages.Msg msg
    }


recipes : Recipes msg
recipes =
    { intro =
        Spa.recipe
            { page = Pages.Guide.Dynamic.Intro.page
            , toModel = IntroModel
            , toMsg = IntroMsg
            }
    , other =
        Spa.recipe
            { page = Pages.Guide.Dynamic.Other.page
            , toModel = OtherModel
            , toMsg = OtherMsg
            }
    , dynamic_folder =
        Spa.recipe
            { page = Generated.Guide.Dynamic.Dynamic.Pages.page
            , toModel = Dynamic_Folder_Model
            , toMsg = Dynamic_Folder_Msg
            }
    , faq_folder =
        Spa.recipe
            { page = Generated.Guide.Dynamic.Faq.Pages.page
            , toModel = Faq_Folder_Model
            , toMsg = Faq_Folder_Msg
            }
    }



-- INIT


init : Route -> Spa.Init Model Msg
init route_ =
    case route_ of
        Route.Intro params ->
            recipes.intro.init params
        
        Route.Other params ->
            recipes.other.init params
        
        Route.Faq_Folder route ->
            recipes.faq_folder.init route
        
        Route.Dynamic_Folder _ route ->
            recipes.dynamic_folder.init route



-- UPDATE


update : Msg -> Model -> Spa.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( IntroMsg msg, IntroModel model ) ->
            recipes.intro.update msg model
        
        ( OtherMsg msg, OtherModel model ) ->
            recipes.other.update msg model
        
        ( Faq_Folder_Msg msg, Faq_Folder_Model model ) ->
            recipes.faq_folder.update msg model
        
        ( Dynamic_Folder_Msg msg, Dynamic_Folder_Model model ) ->
            recipes.dynamic_folder.update msg model
        _ ->
            Spa.Page.keep bigModel


-- BUNDLE


bundle : Model -> Spa.Bundle Msg msg
bundle bigModel =
    case bigModel of
        IntroModel model ->
            recipes.intro.bundle model
        
        OtherModel model ->
            recipes.other.bundle model
        
        Faq_Folder_Model model ->
            recipes.faq_folder.bundle model
        
        Dynamic_Folder_Model model ->
            recipes.dynamic_folder.bundle model
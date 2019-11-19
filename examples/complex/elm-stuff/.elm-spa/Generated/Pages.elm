module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import App.Pattern exposing (static, dynamic)
import Layout as Layout
import Utils.Spa as Spa
import Generated.Params as Params
import Generated.Route as Route exposing (Route)
import Pages.Docs
import Pages.Guide
import Pages.NotFound
import Pages.SignIn
import Pages.Top
import Generated.Docs.Route
import Generated.Guide.Route
import Generated.Docs.Pages
import Generated.Guide.Pages


type Model
    = DocsModel Pages.Docs.Model
    | GuideModel Pages.Guide.Model
    | NotFoundModel Pages.NotFound.Model
    | SignInModel Pages.SignIn.Model
    | TopModel Pages.Top.Model
    | Docs_Folder_Model Generated.Docs.Pages.Model
    | Guide_Folder_Model Generated.Guide.Pages.Model


type Msg
    = DocsMsg Pages.Docs.Msg
    | GuideMsg Pages.Guide.Msg
    | NotFoundMsg Pages.NotFound.Msg
    | SignInMsg Pages.SignIn.Msg
    | TopMsg Pages.Top.Msg
    | Docs_Folder_Msg Generated.Docs.Pages.Msg
    | Guide_Folder_Msg Generated.Guide.Pages.Msg


page : Spa.Page Route Model Msg layoutModel layoutMsg appMsg
page =
    Spa.layout
        { pattern = []
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
    { docs : Recipe Params.Docs Pages.Docs.Model Pages.Docs.Msg msg
    , guide : Recipe Params.Guide Pages.Guide.Model Pages.Guide.Msg msg
    , notFound : Recipe Params.NotFound Pages.NotFound.Model Pages.NotFound.Msg msg
    , signIn : Recipe Params.SignIn Pages.SignIn.Model Pages.SignIn.Msg msg
    , top : Recipe Params.Top Pages.Top.Model Pages.Top.Msg msg
    , docs_folder : Recipe Generated.Docs.Route.Route Generated.Docs.Pages.Model Generated.Docs.Pages.Msg msg
    , guide_folder : Recipe Generated.Guide.Route.Route Generated.Guide.Pages.Model Generated.Guide.Pages.Msg msg
    }


recipes : Recipes msg
recipes =
    { docs =
        Spa.recipe
            { page = Pages.Docs.page
            , toModel = DocsModel
            , toMsg = DocsMsg
            }
    , guide =
        Spa.recipe
            { page = Pages.Guide.page
            , toModel = GuideModel
            , toMsg = GuideMsg
            }
    , notFound =
        Spa.recipe
            { page = Pages.NotFound.page
            , toModel = NotFoundModel
            , toMsg = NotFoundMsg
            }
    , signIn =
        Spa.recipe
            { page = Pages.SignIn.page
            , toModel = SignInModel
            , toMsg = SignInMsg
            }
    , top =
        Spa.recipe
            { page = Pages.Top.page
            , toModel = TopModel
            , toMsg = TopMsg
            }
    , docs_folder =
        Spa.recipe
            { page = Generated.Docs.Pages.page
            , toModel = Docs_Folder_Model
            , toMsg = Docs_Folder_Msg
            }
    , guide_folder =
        Spa.recipe
            { page = Generated.Guide.Pages.page
            , toModel = Guide_Folder_Model
            , toMsg = Guide_Folder_Msg
            }
    }



-- INIT


init : Route -> Spa.Init Model Msg
init route_ =
    case route_ of
        Route.Docs params ->
            recipes.docs.init params
        
        Route.Guide params ->
            recipes.guide.init params
        
        Route.NotFound params ->
            recipes.notFound.init params
        
        Route.SignIn params ->
            recipes.signIn.init params
        
        Route.Top params ->
            recipes.top.init params
        
        Route.Docs_Folder route ->
            recipes.docs_folder.init route
        
        Route.Guide_Folder route ->
            recipes.guide_folder.init route



-- UPDATE


update : Msg -> Model -> Spa.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( DocsMsg msg, DocsModel model ) ->
            recipes.docs.update msg model
        
        ( GuideMsg msg, GuideModel model ) ->
            recipes.guide.update msg model
        
        ( NotFoundMsg msg, NotFoundModel model ) ->
            recipes.notFound.update msg model
        
        ( SignInMsg msg, SignInModel model ) ->
            recipes.signIn.update msg model
        
        ( TopMsg msg, TopModel model ) ->
            recipes.top.update msg model
        
        ( Docs_Folder_Msg msg, Docs_Folder_Model model ) ->
            recipes.docs_folder.update msg model
        
        ( Guide_Folder_Msg msg, Guide_Folder_Model model ) ->
            recipes.guide_folder.update msg model
        _ ->
            App.Page.keep bigModel


-- BUNDLE


bundle : Model -> Spa.Bundle Msg msg
bundle bigModel =
    case bigModel of
        DocsModel model ->
            recipes.docs.bundle model
        
        GuideModel model ->
            recipes.guide.bundle model
        
        NotFoundModel model ->
            recipes.notFound.bundle model
        
        SignInModel model ->
            recipes.signIn.bundle model
        
        TopModel model ->
            recipes.top.bundle model
        
        Docs_Folder_Model model ->
            recipes.docs_folder.bundle model
        
        Guide_Folder_Model model ->
            recipes.guide_folder.bundle model
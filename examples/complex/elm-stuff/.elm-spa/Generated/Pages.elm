module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Docs.Pages
import Generated.Docs.Route
import Generated.Guide.Pages
import Generated.Guide.Route
import Generated.Params as Params
import Generated.Route as Route exposing (Route)
import Layout as Layout
import Pages.Docs
import Pages.Guide
import Pages.NotFound
import Pages.SignIn
import Pages.Top
import Utils.Spa as Spa


type Model
    = TopModel Pages.Top.Model
    | DocsModel Pages.Docs.Model
    | NotFoundModel Pages.NotFound.Model
    | SignInModel Pages.SignIn.Model
    | GuideModel Pages.Guide.Model
    | Guide_Folder_Model Generated.Guide.Pages.Model
    | Docs_Folder_Model Generated.Docs.Pages.Model


type Msg
    = TopMsg Pages.Top.Msg
    | DocsMsg Pages.Docs.Msg
    | NotFoundMsg Pages.NotFound.Msg
    | SignInMsg Pages.SignIn.Msg
    | GuideMsg Pages.Guide.Msg
    | Guide_Folder_Msg Generated.Guide.Pages.Msg
    | Docs_Folder_Msg Generated.Docs.Pages.Msg


page : Spa.Page Route Model Msg layoutModel layoutMsg appMsg
page =
    Spa.layout
        { view = Layout.view
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
    { top : Recipe Params.Top Pages.Top.Model Pages.Top.Msg msg
    , docs : Recipe Params.Docs Pages.Docs.Model Pages.Docs.Msg msg
    , notFound : Recipe Params.NotFound Pages.NotFound.Model Pages.NotFound.Msg msg
    , signIn : Recipe Params.SignIn Pages.SignIn.Model Pages.SignIn.Msg msg
    , guide : Recipe Params.Guide Pages.Guide.Model Pages.Guide.Msg msg
    , guide_folder : Recipe Generated.Guide.Route.Route Generated.Guide.Pages.Model Generated.Guide.Pages.Msg msg
    , docs_folder : Recipe Generated.Docs.Route.Route Generated.Docs.Pages.Model Generated.Docs.Pages.Msg msg
    }


recipes : Recipes msg
recipes =
    { top =
        Spa.recipe
            { page = Pages.Top.page
            , toModel = TopModel
            , toMsg = TopMsg
            }
    , docs =
        Spa.recipe
            { page = Pages.Docs.page
            , toModel = DocsModel
            , toMsg = DocsMsg
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
    , guide =
        Spa.recipe
            { page = Pages.Guide.page
            , toModel = GuideModel
            , toMsg = GuideMsg
            }
    , guide_folder =
        Spa.recipe
            { page = Generated.Guide.Pages.page
            , toModel = Guide_Folder_Model
            , toMsg = Guide_Folder_Msg
            }
    , docs_folder =
        Spa.recipe
            { page = Generated.Docs.Pages.page
            , toModel = Docs_Folder_Model
            , toMsg = Docs_Folder_Msg
            }
    }



-- INIT


init : Route -> Spa.Init Model Msg
init route_ =
    case route_ of
        Route.Top flags ->
            recipes.top.init flags

        Route.Docs flags ->
            recipes.docs.init flags

        Route.NotFound flags ->
            recipes.notFound.init flags

        Route.SignIn flags ->
            recipes.signIn.init flags

        Route.Guide flags ->
            recipes.guide.init flags

        Route.Guide_Folder route ->
            recipes.guide_folder.init route

        Route.Docs_Folder route ->
            recipes.docs_folder.init route



-- UPDATE


update : Msg -> Model -> Spa.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( TopMsg msg, TopModel model ) ->
            recipes.top.update msg model

        ( DocsMsg msg, DocsModel model ) ->
            recipes.docs.update msg model

        ( NotFoundMsg msg, NotFoundModel model ) ->
            recipes.notFound.update msg model

        ( SignInMsg msg, SignInModel model ) ->
            recipes.signIn.update msg model

        ( GuideMsg msg, GuideModel model ) ->
            recipes.guide.update msg model

        ( Guide_Folder_Msg msg, Guide_Folder_Model model ) ->
            recipes.guide_folder.update msg model

        ( Docs_Folder_Msg msg, Docs_Folder_Model model ) ->
            recipes.docs_folder.update msg model

        _ ->
            App.Page.keep bigModel



-- BUNDLE


bundle : Model -> Spa.Bundle Msg msg
bundle bigModel =
    case bigModel of
        TopModel model ->
            recipes.top.bundle model

        DocsModel model ->
            recipes.docs.bundle model

        NotFoundModel model ->
            recipes.notFound.bundle model

        SignInModel model ->
            recipes.signIn.bundle model

        GuideModel model ->
            recipes.guide.bundle model

        Guide_Folder_Model model ->
            recipes.guide_folder.bundle model

        Docs_Folder_Model model ->
            recipes.docs_folder.bundle model

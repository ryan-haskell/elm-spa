module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Docs.Pages
import Generated.Docs.Routes
import Generated.Flags as Flags
import Generated.Guide.Pages
import Generated.Guide.Routes
import Generated.Routes as Routes exposing (Route(..))
import Layout as Layout
import Pages.Docs
import Pages.Guide
import Pages.NotFound
import Pages.SignIn
import Pages.Top
import Utils.Page as Page exposing (Page)


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
    { top : Recipe Flags.Top Pages.Top.Model Pages.Top.Msg msg
    , docs : Recipe Flags.Docs Pages.Docs.Model Pages.Docs.Msg msg
    , notFound : Recipe Flags.NotFound Pages.NotFound.Model Pages.NotFound.Msg msg
    , signIn : Recipe Flags.SignIn Pages.SignIn.Model Pages.SignIn.Msg msg
    , guide : Recipe Flags.Guide Pages.Guide.Model Pages.Guide.Msg msg
    , guide_folder : Recipe Generated.Guide.Routes.Route Generated.Guide.Pages.Model Generated.Guide.Pages.Msg msg
    , docs_folder : Recipe Generated.Docs.Routes.Route Generated.Docs.Pages.Model Generated.Docs.Pages.Msg msg
    }


recipes : Recipes msg
recipes =
    { top =
        Page.recipe
            { page = Pages.Top.page
            , toModel = TopModel
            , toMsg = TopMsg
            }
    , docs =
        Page.recipe
            { page = Pages.Docs.page
            , toModel = DocsModel
            , toMsg = DocsMsg
            }
    , notFound =
        Page.recipe
            { page = Pages.NotFound.page
            , toModel = NotFoundModel
            , toMsg = NotFoundMsg
            }
    , signIn =
        Page.recipe
            { page = Pages.SignIn.page
            , toModel = SignInModel
            , toMsg = SignInMsg
            }
    , guide =
        Page.recipe
            { page = Pages.Guide.page
            , toModel = GuideModel
            , toMsg = GuideMsg
            }
    , guide_folder =
        Page.recipe
            { page = Generated.Guide.Pages.page
            , toModel = Guide_Folder_Model
            , toMsg = Guide_Folder_Msg
            }
    , docs_folder =
        Page.recipe
            { page = Generated.Docs.Pages.page
            , toModel = Docs_Folder_Model
            , toMsg = Docs_Folder_Msg
            }
    }



-- INIT


init : Route -> Page.Init Model Msg
init route_ =
    case route_ of
        Routes.Top flags ->
            recipes.top.init flags

        Routes.Docs flags ->
            recipes.docs.init flags

        Routes.NotFound flags ->
            recipes.notFound.init flags

        Routes.SignIn flags ->
            recipes.signIn.init flags

        Routes.Guide flags ->
            recipes.guide.init flags

        Routes.Guide_Folder route ->
            recipes.guide_folder.init route

        Routes.Docs_Folder route ->
            recipes.docs_folder.init route



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg
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


bundle : Model -> Page.Bundle Msg msg
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

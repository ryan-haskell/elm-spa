module Generated.Guide.Dynamic.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Guide.Dynamic.Flags as Flags
import Generated.Guide.Dynamic.Routes as Routes exposing (Route(..))
import Layouts.Guide.Dynamic as Layout
import Pages.Guide.Dynamic.Intro
import Utils.Page as Page exposing (Page)


type Model
    = IntroModel Pages.Guide.Dynamic.Intro.Model


type Msg
    = IntroMsg Pages.Guide.Dynamic.Intro.Msg


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
    { intro : Recipe Flags.Intro Pages.Guide.Dynamic.Intro.Model Pages.Guide.Dynamic.Intro.Msg msg
    }


recipes : Recipes msg
recipes =
    { intro =
        Page.recipe
            { page = Pages.Guide.Dynamic.Intro.page
            , toModel = IntroModel
            , toMsg = IntroMsg
            }
    }



-- INIT


init : Route -> Page.Init Model Msg
init route =
    case route of
        Routes.Intro flags ->
            recipes.intro.init flags



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( IntroMsg msg, IntroModel model ) ->
            recipes.intro.update msg model



-- _ ->
--     App.Page.keep bigModel
-- BUNDLE


bundle : Model -> Page.Bundle Msg msg
bundle bigModel =
    case bigModel of
        IntroModel model ->
            recipes.intro.bundle model

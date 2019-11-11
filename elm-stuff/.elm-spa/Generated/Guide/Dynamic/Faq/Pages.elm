module Generated.Guide.Dynamic.Faq.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Guide.Dynamic.Faq.Params as Params
import Generated.Guide.Dynamic.Faq.Route as Route exposing (Route(..))
import Layouts.Guide.Dynamic.Faq as Layout
import Pages.Guide.Dynamic.Faq.Top
import Utils.Page as Page exposing (Page)


type Model
    = TopModel Pages.Guide.Dynamic.Faq.Top.Model


type Msg
    = TopMsg Pages.Guide.Dynamic.Faq.Top.Msg


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
    { top : Recipe Params.Top Pages.Guide.Dynamic.Faq.Top.Model Pages.Guide.Dynamic.Faq.Top.Msg msg
    }


recipes : Recipes msg
recipes =
    { top =
        Page.recipe
            { page = Pages.Guide.Dynamic.Faq.Top.page
            , toModel = TopModel
            , toMsg = TopMsg
            }
    }



-- INIT


init : Route -> Page.Init Model Msg
init route =
    case route of
        Route.Top flags ->
            recipes.top.init flags



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( TopMsg msg, TopModel model ) ->
            recipes.top.update msg model



-- _ ->
--     App.Page.keep bigModel
-- BUNDLE


bundle : Model -> Page.Bundle Msg msg
bundle bigModel =
    case bigModel of
        TopModel model ->
            recipes.top.bundle model

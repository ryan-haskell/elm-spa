module Generated.Guide.Dynamic.Faq.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Layouts.Guide.Dynamic.Faq as Layout
import Utils.Spa as Spa
import Generated.Guide.Dynamic.Faq.Params as Params
import Generated.Guide.Dynamic.Faq.Route as Route exposing (Route)
import Pages.Guide.Dynamic.Faq.Top




type Model
    = TopModel Pages.Guide.Dynamic.Faq.Top.Model


type Msg
    = TopMsg Pages.Guide.Dynamic.Faq.Top.Msg


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
    { top : Recipe Params.Top Pages.Guide.Dynamic.Faq.Top.Model Pages.Guide.Dynamic.Faq.Top.Msg msg
    }


recipes : Recipes msg
recipes =
    { top =
        Spa.recipe
            { page = Pages.Guide.Dynamic.Faq.Top.page
            , toModel = TopModel
            , toMsg = TopMsg
            }
    }



-- INIT


init : Route -> Spa.Init Model Msg
init route_ =
    case route_ of
        Route.Top params ->
            recipes.top.init params



-- UPDATE


update : Msg -> Model -> Spa.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( TopMsg msg, TopModel model ) ->
            recipes.top.update msg model



-- BUNDLE


bundle : Model -> Spa.Bundle Msg msg
bundle bigModel =
    case bigModel of
        TopModel model ->
            recipes.top.bundle model
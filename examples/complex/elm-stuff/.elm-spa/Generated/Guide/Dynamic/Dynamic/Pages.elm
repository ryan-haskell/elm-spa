module Generated.Guide.Dynamic.Dynamic.Pages exposing
    ( Model
    , Msg
    , page
    )

import Spa.Page
import Spa.Pattern exposing (static, dynamic)
import Layouts.Guide.Dynamic.Dynamic as Layout
import Utils.Spa as Spa
import Generated.Guide.Dynamic.Dynamic.Params as Params
import Generated.Guide.Dynamic.Dynamic.Route as Route exposing (Route)
import Pages.Guide.Dynamic.Dynamic.Top




type Model
    = TopModel Pages.Guide.Dynamic.Dynamic.Top.Model


type Msg
    = TopMsg Pages.Guide.Dynamic.Dynamic.Top.Msg


page : Spa.Page Route Model Msg layoutModel layoutMsg appMsg
page =
    Spa.layout
        { pattern = [ static "guide", dynamic, dynamic ]
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
    { top : Recipe Params.Top Pages.Guide.Dynamic.Dynamic.Top.Model Pages.Guide.Dynamic.Dynamic.Top.Msg msg
    }


recipes : Recipes msg
recipes =
    { top =
        Spa.recipe
            { page = Pages.Guide.Dynamic.Dynamic.Top.page
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
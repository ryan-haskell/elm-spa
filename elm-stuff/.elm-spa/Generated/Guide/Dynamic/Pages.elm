module Generated.Guide.Dynamic.Pages exposing
    ( Model
    , Msg
    , page
    )

import App.Page
import Generated.Guide.Dynamic.Params as Params
import Generated.Guide.Dynamic.Route as Route exposing (Route)
import Layouts.Guide.Dynamic as Layout
import Pages.Guide.Dynamic.Intro
import Pages.Guide.Dynamic.Other
import Utils.Page as Page exposing (Page)


type Model
    = IntroModel Pages.Guide.Dynamic.Intro.Model
    | OtherModel Pages.Guide.Dynamic.Other.Model


type Msg
    = IntroMsg Pages.Guide.Dynamic.Intro.Msg
    | OtherMsg Pages.Guide.Dynamic.Other.Msg


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
    }



-- INIT


init : Route -> Page.Init Model Msg
init route =
    case route of
        Route.Intro flags ->
            recipes.intro.init flags

        Route.Other flags ->
            recipes.other.init flags



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( IntroMsg msg, IntroModel model ) ->
            recipes.intro.update msg model

        ( OtherMsg msg, OtherModel model ) ->
            recipes.other.update msg model

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

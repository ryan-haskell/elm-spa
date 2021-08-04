module Gen.Pages_ exposing (Model, Msg, init, layout, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import ElmSpa.Page
import Gen.Layouts
import Gen.Model as Model
import Gen.Msg as Msg
import Gen.Params.Apps
import Gen.Params.Devices
import Gen.Params.Home_
import Gen.Params.NotFound
import Gen.Params.People
import Gen.Params.Settings.General
import Gen.Params.Settings.Profile
import Gen.Params.SignIn
import Gen.Route as Route exposing (Route)
import Page exposing (Page)
import Pages.Apps
import Pages.Devices
import Pages.Home_
import Pages.NotFound
import Pages.People
import Pages.Settings.General
import Pages.Settings.Profile
import Pages.SignIn
import Request exposing (Request)
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


type alias Model =
    Model.Model


type alias Msg =
    Msg.Msg


init : Route -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
init route =
    case route of
        Route.Apps ->
            pages.apps.init ()

        Route.Devices ->
            pages.devices.init ()

        Route.Home_ ->
            pages.home_.init ()

        Route.People ->
            pages.people.init ()

        Route.SignIn ->
            pages.signIn.init ()

        Route.Settings__General ->
            pages.settings__general.init ()

        Route.Settings__Profile ->
            pages.settings__profile.init ()

        Route.NotFound ->
            pages.notFound.init ()


update : Msg -> Model -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        _ ->
            \_ _ _ -> ( model_, Effect.none )


view : Model -> Shared.Model -> Url -> Key -> View Msg
view model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> View.none

        Model.Apps params ->
            pages.apps.view params ()

        Model.Devices params ->
            pages.devices.view params ()

        Model.Home_ params ->
            pages.home_.view params ()

        Model.People params ->
            pages.people.view params ()

        Model.SignIn params ->
            pages.signIn.view params ()

        Model.Settings__General params ->
            pages.settings__general.view params ()

        Model.Settings__Profile params ->
            pages.settings__profile.view params ()

        Model.NotFound params ->
            pages.notFound.view params ()


subscriptions : Model -> Shared.Model -> Url -> Key -> Sub Msg
subscriptions model_ =
    case model_ of
        Model.Redirecting_ ->
            \_ _ _ -> Sub.none

        Model.Apps params ->
            pages.apps.subscriptions params ()

        Model.Devices params ->
            pages.devices.subscriptions params ()

        Model.Home_ params ->
            pages.home_.subscriptions params ()

        Model.People params ->
            pages.people.subscriptions params ()

        Model.SignIn params ->
            pages.signIn.subscriptions params ()

        Model.Settings__General params ->
            pages.settings__general.subscriptions params ()

        Model.Settings__Profile params ->
            pages.settings__profile.subscriptions params ()

        Model.NotFound params ->
            pages.notFound.subscriptions params ()



-- INTERNALS


pages :
    { apps : Static Gen.Params.Apps.Params
    , devices : Static Gen.Params.Devices.Params
    , home_ : Static Gen.Params.Home_.Params
    , people : Static Gen.Params.People.Params
    , signIn : Static Gen.Params.SignIn.Params
    , settings__general : Static Gen.Params.Settings.General.Params
    , settings__profile : Static Gen.Params.Settings.Profile.Params
    , notFound : Static Gen.Params.NotFound.Params
    }
pages =
    { apps = static Pages.Apps.view Model.Apps
    , devices = static Pages.Devices.view Model.Devices
    , home_ = static Pages.Home_.view Model.Home_
    , people = static Pages.People.view Model.People
    , signIn = static Pages.SignIn.view Model.SignIn
    , settings__general = static Pages.Settings.General.view Model.Settings__General
    , settings__profile = static Pages.Settings.Profile.view Model.Settings__Profile
    , notFound = static Pages.NotFound.view Model.NotFound
    }


type alias Bundle params model msg =
    ElmSpa.Page.Bundle params model msg Shared.Model (Effect Msg) Model Msg (View Msg)


bundle page toModel toMsg =
    ElmSpa.Page.bundle
        { redirecting =
            { model = Model.Redirecting_
            , view = View.none
            }
        , toRoute = Route.fromUrl
        , toUrl = Route.toHref
        , fromCmd = Effect.fromCmd
        , mapEffect = Effect.map toMsg
        , mapView = View.map toMsg
        , toModel = toModel
        , toMsg = toMsg
        , page = page
        }


type alias Static params =
    Bundle params () Never


static : View Never -> (params -> Model) -> Static params
static view_ toModel =
    { init = \params _ _ _ -> ( toModel params, Effect.none )
    , update = \params _ _ _ _ _ -> ( toModel params, Effect.none )
    , view = \_ _ _ _ _ -> View.map never view_
    , subscriptions = \_ _ _ _ _ -> Sub.none
    }



-- LAYOUTS


layout : Route -> Maybe Gen.Layouts.Layout
layout route =
    case route of
        Route.Home_ ->
            Just Pages.Home_.layout

        Route.Apps ->
            Just Pages.Apps.layout

        Route.Devices ->
            Just Pages.Devices.layout

        Route.People ->
            Just Pages.People.layout

        Route.Settings__General ->
            Just Pages.Settings.General.layout

        Route.Settings__Profile ->
            Just Pages.Settings.Profile.layout

        Route.SignIn ->
            Nothing

        Route.NotFound ->
            Nothing

module Generated.Pages exposing
    ( Model
    , Msg
    , Route(..)
    , bundle
    , init
    , routes
    , update
    )

import Application.Page as Page
import Application.Route as Route
import Generated.Pages.Settings as Settings
import Global
import Pages.Counter as Counter
import Pages.Index as Index
import Pages.NotFound as NotFound
import Pages.Random as Random
import Pages.SignIn as SignIn



-- ROUTES


type Route
    = CounterRoute Counter.Route
    | IndexRoute Index.Route
    | NotFoundRoute NotFound.Route
    | RandomRoute Random.Route
    | SignInRoute SignIn.Route
    | SettingsRoute Settings.Route


routes : List (Route.Route Route)
routes =
    [ Route.path "counter" CounterRoute
    , Route.index IndexRoute
    , Route.path "not-found" NotFoundRoute
    , Route.path "random" RandomRoute
    , Route.path "sign-in" SignInRoute
    , Route.folder "settings" SettingsRoute Settings.routes
    ]



-- MODEL & MSG


type Model
    = CounterModel Counter.Model
    | IndexModel Index.Model
    | NotFoundModel NotFound.Model
    | RandomModel Random.Model
    | SignInModel SignIn.Model
    | SettingsModel Settings.Model


type Msg
    = CounterMsg Counter.Msg
    | IndexMsg Index.Msg
    | NotFoundMsg NotFound.Msg
    | RandomMsg Random.Msg
    | SignInMsg SignIn.Msg
    | SettingsMsg Settings.Msg



-- RECIPES


counter : Page.Recipe Counter.Route Counter.Model Counter.Msg Model Msg Global.Model Global.Msg a
counter =
    Counter.page
        { toModel = CounterModel
        , toMsg = CounterMsg
        }


index : Page.Recipe Index.Route Index.Model Index.Msg Model Msg Global.Model Global.Msg a
index =
    Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        }


notFound : Page.Recipe NotFound.Route NotFound.Model NotFound.Msg Model Msg Global.Model Global.Msg a
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }


random : Page.Recipe Random.Route Random.Model Random.Msg Model Msg Global.Model Global.Msg a
random =
    Random.page
        { toModel = RandomModel
        , toMsg = RandomMsg
        }


signIn : Page.Recipe SignIn.Route SignIn.Model SignIn.Msg Model Msg Global.Model Global.Msg a
signIn =
    SignIn.page
        { toModel = SignInModel
        , toMsg = SignInMsg
        }


settings : Page.Recipe Settings.Route Settings.Model Settings.Msg Model Msg Global.Model Global.Msg a
settings =
    Settings.page
        { toModel = SettingsModel
        , toMsg = SettingsMsg
        }



-- INIT


init : Route -> Page.Init Model Msg Global.Model Global.Msg
init route_ =
    case route_ of
        CounterRoute route ->
            counter.init route

        IndexRoute route ->
            index.init route

        NotFoundRoute route ->
            notFound.init route

        RandomRoute route ->
            random.init route

        SignInRoute route ->
            signIn.init route

        SettingsRoute route ->
            settings.init route



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg Global.Model Global.Msg
update msg_ model_ =
    case ( msg_, model_ ) of
        ( CounterMsg msg, CounterModel model ) ->
            counter.update msg model

        ( IndexMsg msg, IndexModel model ) ->
            index.update msg model

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        ( RandomMsg msg, RandomModel model ) ->
            random.update msg model

        ( SignInMsg msg, SignInModel model ) ->
            signIn.update msg model

        ( SettingsMsg msg, SettingsModel model ) ->
            settings.update msg model

        _ ->
            Page.keep model_



-- BUNDLE


bundle : Model -> Page.Bundle Msg Global.Model Global.Msg a
bundle model_ =
    case model_ of
        CounterModel model ->
            counter.bundle model

        IndexModel model ->
            index.bundle model

        NotFoundModel model ->
            notFound.bundle model

        RandomModel model ->
            random.bundle model

        SignInModel model ->
            signIn.bundle model

        SettingsModel model ->
            settings.bundle model

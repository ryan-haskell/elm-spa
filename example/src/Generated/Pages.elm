module Generated.Pages exposing
    ( Model
    , Msg
    , Route(..)
    , bundle
    , init
    , routes
    , update
    )

import Application
import Application.Route as Route
import Generated.Pages.Settings as Settings
import Pages.Counter as Counter
import Pages.Index as Index
import Pages.NotFound as NotFound
import Pages.Random as Random



-- ROUTES


type Route
    = CounterRoute Counter.Route
    | IndexRoute Index.Route
    | NotFoundRoute NotFound.Route
    | RandomRoute Random.Route
    | SettingsRoute Settings.Route


routes : Application.Routes Route
routes =
    [ Route.path "counter" CounterRoute
    , Route.index IndexRoute
    , Route.path "not-found" NotFoundRoute
    , Route.path "random" RandomRoute
    , Route.folder "settings" SettingsRoute Settings.routes
    ]



-- MODEL & MSG


type Model
    = CounterModel Counter.Model
    | IndexModel Index.Model
    | NotFoundModel NotFound.Model
    | RandomModel Random.Model
    | SettingsModel Settings.Model


type Msg
    = CounterMsg Counter.Msg
    | IndexMsg Index.Msg
    | NotFoundMsg NotFound.Msg
    | RandomMsg Random.Msg
    | SettingsMsg Settings.Msg



-- RECIPES


counter : Application.Recipe Counter.Route Counter.Model Counter.Msg Model Msg
counter =
    Counter.page
        { toModel = CounterModel
        , toMsg = CounterMsg
        }


index : Application.Recipe Index.Route Index.Model Index.Msg Model Msg
index =
    Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        }


notFound : Application.Recipe NotFound.Route NotFound.Model NotFound.Msg Model Msg
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }


random : Application.Recipe Random.Route Random.Model Random.Msg Model Msg
random =
    Random.page
        { toModel = RandomModel
        , toMsg = RandomMsg
        }


settings : Application.Recipe Settings.Route Settings.Model Settings.Msg Model Msg
settings =
    Settings.page
        { toModel = SettingsModel
        , toMsg = SettingsMsg
        }



-- INIT


init : Route -> Application.Init Model Msg
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

        SettingsRoute route ->
            settings.init route



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
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

        ( SettingsMsg msg, SettingsModel model ) ->
            settings.update msg model

        _ ->
            Application.keep model_



-- BUNDLE


bundle : Model -> Application.Bundle Msg
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

        SettingsModel model ->
            settings.bundle model

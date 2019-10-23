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
import Generated.Pages.Settings as Settings
import Html exposing (Html)
import Pages.Counter as Counter
import Pages.Homepage as Homepage
import Pages.NotFound as NotFound
import Pages.Random as Random
import Url.Parser as Parser exposing (Parser, (</>))


type Route
    = HomepageRoute Homepage.Params
    | CounterRoute Counter.Params
    | RandomRoute Random.Params
    | SettingsRoute Settings.Params
    | NotFoundRoute NotFound.Params 


type Model
    = HomepageModel Homepage.Model
    | CounterModel Counter.Model
    | RandomModel Random.Model
    | SettingsModel Settings.Model
    | NotFoundModel NotFound.Model


type Msg
    = HomepageMsg Homepage.Msg
    | CounterMsg Counter.Msg
    | RandomMsg Random.Msg
    | SettingsMsg Settings.Msg
    | NotFoundMsg NotFound.Msg


homepage : Application.Recipe Homepage.Params Homepage.Model Homepage.Msg Route Model Msg
homepage = 
    Homepage.page
        { toRoute = HomepageRoute
        , toModel = HomepageModel
        , toMsg = HomepageMsg
        }


counter : Application.Recipe Counter.Params Counter.Model Counter.Msg Route Model Msg
counter =
    Counter.page
        { toRoute = CounterRoute
        , toModel = CounterModel
        , toMsg = CounterMsg
        }
 

random : Application.Recipe Random.Params Random.Model Random.Msg Route Model Msg
random =
    Random.page
        { toRoute = RandomRoute
        , toModel = RandomModel
        , toMsg = RandomMsg
        } 


settings : Application.Recipe Settings.Params Settings.Model Settings.Msg Route Model Msg
settings =
    Settings.page
        { toRoute = SettingsRoute
        , toModel = SettingsModel
        , toMsg = SettingsMsg
        }


notFound : Application.Recipe NotFound.Params NotFound.Model NotFound.Msg Route Model Msg
notFound =
    NotFound.page
        { toRoute = NotFoundRoute
        , toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }
 

routes : Application.Routes Route
routes =
    [ homepage.route
    , counter.route
    , random.route
    , settings.route
    ]


init : Route -> Application.Init Model Msg
init route =
    case route of
        HomepageRoute params ->
            homepage.init params

        CounterRoute params ->
            counter.init params

        RandomRoute params ->
            random.init params

        SettingsRoute params ->
            settings.init params

        NotFoundRoute params ->
            notFound.init params


update : Msg -> Model -> ( Model, Cmd Msg )
update appMsg appModel =
    case ( appMsg, appModel ) of
        ( HomepageMsg msg, HomepageModel model ) ->
            homepage.update msg model

        ( CounterMsg msg, CounterModel model ) ->
            counter.update msg model

        ( RandomMsg msg, RandomModel model ) ->
            random.update msg model

        ( SettingsMsg msg, SettingsModel model ) ->
            settings.update msg model

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        _ ->
            Application.keep appModel


bundle : Model -> Application.Bundle Msg
bundle appModel =
    case appModel of
        HomepageModel model ->
            homepage.bundle model

        CounterModel model ->
            counter.bundle model

        RandomModel model ->
            random.bundle model

        SettingsModel model ->
            settings.bundle model

        NotFoundModel model ->
            notFound.bundle model

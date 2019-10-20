module Generated.Pages exposing (Model, Msg, bundle, init, update)

import Application
import Generated.Pages.Settings as Settings
import Generated.Route as Route exposing (Route)
import Html exposing (Html)
import Pages.Counter as Counter
import Pages.Homepage as Homepage
import Pages.NotFound as NotFound
import Pages.Random as Random
import Pages.Users.Slug as Users_Slug
import Pages.Users.Slug.Posts.Slug as Users_Slug_Posts_Slug


type Model
    = HomepageModel Homepage.Model
    | CounterModel Counter.Model
    | RandomModel Random.Model
    | NotFoundModel NotFound.Model
    | SettingsModel Settings.Model
    | Users_SlugModel Users_Slug.Model
    | Users_Slug_Posts_SlugModel Users_Slug_Posts_Slug.Model


type Msg
    = HomepageMsg Homepage.Msg
    | CounterMsg Counter.Msg
    | RandomMsg Random.Msg
    | SettingsMsg Settings.Msg
    | NotFoundMsg NotFound.Msg
    | Users_SlugMsg Users_Slug.Msg
    | Users_Slug_Posts_SlugMsg Users_Slug_Posts_Slug.Msg


homepage : Application.Recipe Homepage.Params Homepage.Model Homepage.Msg Model Msg
homepage =
    Homepage.page
        { toModel = HomepageModel
        , toMsg = HomepageMsg
        }


counter : Application.Recipe Counter.Params Counter.Model Counter.Msg Model Msg
counter =
    Counter.page
        { toModel = CounterModel
        , toMsg = CounterMsg
        }


random : Application.Recipe Random.Params Random.Model Random.Msg Model Msg
random =
    Random.page
        { toModel = RandomModel
        , toMsg = RandomMsg
        }


settings : Application.Recipe Settings.Params Settings.Model Settings.Msg Model Msg
settings =
    Settings.page
        { toModel = SettingsModel
        , toMsg = SettingsMsg
        }


notFound : Application.Recipe NotFound.Params NotFound.Model NotFound.Msg Model Msg
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }


users_slug : Application.Recipe Users_Slug.Params Users_Slug.Model Users_Slug.Msg Model Msg
users_slug =
    Users_Slug.page
        { toModel = Users_SlugModel
        , toMsg = Users_SlugMsg
        }


users_slug_posts_slug : Application.Recipe Users_Slug_Posts_Slug.Params Users_Slug_Posts_Slug.Model Users_Slug_Posts_Slug.Msg Model Msg
users_slug_posts_slug =
    Users_Slug_Posts_Slug.page
        { toModel = Users_Slug_Posts_SlugModel
        , toMsg = Users_Slug_Posts_SlugMsg
        }


init : Route -> Application.Init Model Msg
init route =
    case route of
        Route.Homepage params ->
            homepage.init params

        Route.Counter params ->
            counter.init params

        Route.Random params ->
            random.init params

        Route.Settings params ->
            settings.init params

        Route.NotFound params ->
            notFound.init params

        Route.Users_Slug params ->
            users_slug.init params

        Route.Users_Slug_Posts_Slug params ->
            users_slug_posts_slug.init params


update : Msg -> Model -> ( Model, Cmd Msg )
update appMsg appModel =
    case ( appMsg, appModel ) of
        ( HomepageMsg msg, HomepageModel model ) ->
            homepage.update msg model

        ( HomepageMsg _, _ ) ->
            Application.keep appModel

        ( CounterMsg msg, CounterModel model ) ->
            counter.update msg model

        ( CounterMsg _, _ ) ->
            Application.keep appModel

        ( RandomMsg msg, RandomModel model ) ->
            random.update msg model

        ( RandomMsg _, _ ) ->
            Application.keep appModel

        ( SettingsMsg msg, SettingsModel model ) ->
            settings.update msg model

        ( SettingsMsg _, _ ) ->
            Application.keep appModel

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        ( NotFoundMsg _, _ ) ->
            Application.keep appModel

        ( Users_SlugMsg msg, Users_SlugModel model ) ->
            users_slug.update msg model

        ( Users_SlugMsg _, _ ) ->
            Application.keep appModel

        ( Users_Slug_Posts_SlugMsg msg, Users_Slug_Posts_SlugModel model ) ->
            users_slug_posts_slug.update msg model

        ( Users_Slug_Posts_SlugMsg _, _ ) ->
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

        Users_SlugModel model ->
            users_slug.bundle model

        Users_Slug_Posts_SlugModel model ->
            users_slug_posts_slug.bundle model

module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
import Generated.Pages.Settings as Settings
import Generated.Pages.Users as Users
import Generated.Route as Route
import Html
import Layouts.Main as Layout
import Pages.Counter as Counter
import Pages.Index as Index
import Pages.NotFound as NotFound
import Pages.Random as Random
import Pages.SignIn as SignIn


type Model
    = CounterModel Counter.Model
    | IndexModel Index.Model
    | NotFoundModel NotFound.Model
    | RandomModel Random.Model
    | SettingsModel Settings.Model
    | SignInModel SignIn.Model
    | UsersModel Users.Model


type Msg
    = CounterMsg Counter.Msg
    | IndexMsg Index.Msg
    | NotFoundMsg NotFound.Msg
    | RandomMsg Random.Msg
    | SettingsMsg Settings.Msg
    | SignInMsg SignIn.Msg
    | UsersMsg Users.Msg


page =
    Page.layout
        { map = Html.map
        , view = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


counter =
    Counter.page
        { toModel = CounterModel
        , toMsg = CounterMsg
        , map = Html.map
        }


index =
    Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        , map = Html.map
        }


notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        , map = Html.map
        }


random =
    Random.page
        { toModel = RandomModel
        , toMsg = RandomMsg
        , map = Html.map
        }


settings =
    Settings.page
        { toModel = SettingsModel
        , toMsg = SettingsMsg
        , map = Html.map
        }


signIn =
    SignIn.page
        { toModel = SignInModel
        , toMsg = SignInMsg
        , map = Html.map
        }


users =
    Users.page
        { toModel = UsersModel
        , toMsg = UsersMsg
        , map = Html.map
        }


init route_ =
    case route_ of
        Route.Counter route ->
            counter.init route

        Route.Index route ->
            index.init route

        Route.NotFound route ->
            notFound.init route

        Route.Random route ->
            random.init route

        Route.Settings route ->
            settings.init route

        Route.SignIn route ->
            signIn.init route

        Route.Users route ->
            users.init route


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

        ( SignInMsg msg, SignInModel model ) ->
            signIn.update msg model

        ( UsersMsg msg, UsersModel model ) ->
            users.update msg model

        _ ->
            Page.keep model_


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

        SignInModel model ->
            signIn.bundle model

        UsersModel model ->
            users.bundle model


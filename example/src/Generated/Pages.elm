module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page exposing (Page)
import Generated.Pages.Settings as Settings
import Generated.Pages.Users as Users
import Generated.Route as Route exposing (Route)
import Global
import Layouts.Main as Layout
import Pages.Counter as Counter
import Pages.Index as Index
import Pages.NotFound as NotFound
import Pages.Random as Random
import Pages.SignIn as SignIn



-- MODEL & MSG


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


page : Page Route Model Msg a b Global.Model Global.Msg c
page =
    Page.layout
        { layout = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }



-- RECIPES


type alias Recipe params model msg a =
    Page.Recipe params model msg Model Msg Global.Model Global.Msg a


counter : Recipe Route.CounterParams Counter.Model Counter.Msg a
counter =
    Counter.page
        { toModel = CounterModel
        , toMsg = CounterMsg
        }


index : Recipe Route.IndexParams Index.Model Index.Msg a
index =
    Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        }


notFound : Recipe Route.NotFoundParams NotFound.Model NotFound.Msg a
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }


random : Recipe Route.RandomParams Random.Model Random.Msg a
random =
    Random.page
        { toModel = RandomModel
        , toMsg = RandomMsg
        }


settings : Recipe Route.SettingsParams Settings.Model Settings.Msg a
settings =
    Settings.page
        { toModel = SettingsModel
        , toMsg = SettingsMsg
        }


signIn : Recipe Route.SignInParams SignIn.Model SignIn.Msg a
signIn =
    SignIn.page
        { toModel = SignInModel
        , toMsg = SignInMsg
        }


users : Recipe Route.UsersParams Users.Model Users.Msg a
users =
    Users.page
        { toModel = UsersModel
        , toMsg = UsersMsg
        }



-- INIT


init : Route -> Page.Init Model Msg Global.Model Global.Msg
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

        ( SettingsMsg msg, SettingsModel model ) ->
            settings.update msg model

        ( SignInMsg msg, SignInModel model ) ->
            signIn.update msg model

        ( UsersMsg msg, UsersModel model ) ->
            users.update msg model

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

        SettingsModel model ->
            settings.bundle model

        SignInModel model ->
            signIn.bundle model

        UsersModel model ->
            users.bundle model

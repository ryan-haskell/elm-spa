module Templates.TopLevelPages exposing (contents)

import Item exposing (Item)


contents : List Item -> String
contents items =
    """module Generated.Pages exposing
    ( Model
    , Msg
    , bundle
    , init
    , update
    )

import Application.Page as Page
import Generated.Pages.Settings as Settings
import Generated.Pages.Users as Users
import Generated.Route as Route exposing (Route)
import Global
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
    | SignInModel SignIn.Model
    | SettingsModel Settings.Model
    | UsersModel Users.Model


type Msg
    = CounterMsg Counter.Msg
    | IndexMsg Index.Msg
    | NotFoundMsg NotFound.Msg
    | RandomMsg Random.Msg
    | SignInMsg SignIn.Msg
    | SettingsMsg Settings.Msg
    | UsersMsg Users.Msg



-- RECIPES


counter : Page.Recipe Route.CounterParams Counter.Model Counter.Msg Model Msg Global.Model Global.Msg a
counter =
    Counter.page
        { toModel = CounterModel
        , toMsg = CounterMsg
        }


index : Page.Recipe Route.IndexParams Index.Model Index.Msg Model Msg Global.Model Global.Msg a
index =
    Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        }


notFound : Page.Recipe Route.NotFoundParams NotFound.Model NotFound.Msg Model Msg Global.Model Global.Msg a
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }


random : Page.Recipe Route.RandomParams Random.Model Random.Msg Model Msg Global.Model Global.Msg a
random =
    Random.page
        { toModel = RandomModel
        , toMsg = RandomMsg
        }


signIn : Page.Recipe Route.SignInParams SignIn.Model SignIn.Msg Model Msg Global.Model Global.Msg a
signIn =
    SignIn.page
        { toModel = SignInModel
        , toMsg = SignInMsg
        }


settings : Page.Recipe Route.SettingsParams Settings.Model Settings.Msg Model Msg Global.Model Global.Msg a
settings =
    Settings.page
        { toModel = SettingsModel
        , toMsg = SettingsMsg
        }


users : Page.Recipe Route.UsersParams Users.Model Users.Msg Model Msg Global.Model Global.Msg a
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

        Route.SignIn route ->
            signIn.init route

        Route.Settings route ->
            settings.init route

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

        ( SignInMsg msg, SignInModel model ) ->
            signIn.update msg model

        ( SettingsMsg msg, SettingsModel model ) ->
            settings.update msg model

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

        SignInModel model ->
            signIn.bundle model

        SettingsModel model ->
            settings.bundle model

        UsersModel model ->
            users.bundle model

"""

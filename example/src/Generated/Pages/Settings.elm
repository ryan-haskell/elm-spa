module Generated.Pages.Settings exposing
    ( Model
    , Msg
    , Route
    , page
    , routes
    )

import Application
import Application.Route as Route
import Html exposing (..)
import Layouts.Settings
import Pages.Settings.Account as Account
import Pages.Settings.Notifications as Notifications
import Pages.Settings.User as User


type Route
    = AccountRoute Account.Route
    | NotificationsRoute Notifications.Route
    | UserRoute User.Route


type Model
    = AccountModel Account.Model
    | NotificationsModel Notifications.Model
    | UserModel User.Model


type Msg
    = AccountMsg Account.Msg
    | NotificationsMsg Notifications.Msg
    | UserMsg User.Msg


page : Application.Page Route Model Msg model msg
page =
    Application.glue
        { layout = Layouts.Settings.layout
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


routes : Application.Routes Route
routes =
    [ Route.path "account" AccountRoute
    , Route.path "notifications" NotificationsRoute
    , Route.path "user" UserRoute
    ]


account : Application.Recipe Account.Route Account.Model Account.Msg Model Msg
account =
    Account.page
        { toModel = AccountModel
        , toMsg = AccountMsg
        }


notifications : Application.Recipe Notifications.Route Notifications.Model Notifications.Msg Model Msg
notifications =
    Notifications.page
        { toModel = NotificationsModel
        , toMsg = NotificationsMsg
        }


user : Application.Recipe User.Route User.Model User.Msg Model Msg
user =
    User.page
        { toModel = UserModel
        , toMsg = UserMsg
        }


init : Route -> Application.Init Model Msg
init route_ =
    case route_ of
        AccountRoute route ->
            account.init route

        NotificationsRoute route ->
            notifications.init route

        UserRoute route ->
            user.init route


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        ( AccountMsg msg, AccountModel model ) ->
            account.update msg model

        ( NotificationsMsg msg, NotificationsModel model ) ->
            notifications.update msg model

        ( UserMsg msg, UserModel model ) ->
            user.update msg model

        _ ->
            Application.keep model_


bundle : Model -> Application.Bundle Msg
bundle model_ =
    case model_ of
        AccountModel model ->
            account.bundle model

        NotificationsModel model ->
            notifications.bundle model

        UserModel model ->
            user.bundle model

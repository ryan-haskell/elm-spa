module Generated.Pages.Settings exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Application
import Generated.Route.Settings as Route exposing (Route)
import Global
import Html exposing (..)
import Layouts.Settings as Layout
import Pages.Settings.Account as Account
import Pages.Settings.Notifications as Notifications
import Pages.Settings.User as User


type Model
    = AccountModel Account.Model
    | NotificationsModel Notifications.Model
    | UserModel User.Model


type Msg
    = AccountMsg Account.Msg
    | NotificationsMsg Notifications.Msg
    | UserMsg User.Msg


page : Application.Page Route Model Msg a b Global.Model Global.Msg c
page =
    Application.layout
        { layout = Layout.layout
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


account : Application.Recipe Route.AccountParams Account.Model Account.Msg Model Msg Global.Model Global.Msg a
account =
    Account.page
        { toModel = AccountModel
        , toMsg = AccountMsg
        }


notifications : Application.Recipe Route.NotificationsParams Notifications.Model Notifications.Msg Model Msg Global.Model Global.Msg a
notifications =
    Notifications.page
        { toModel = NotificationsModel
        , toMsg = NotificationsMsg
        }


user : Application.Recipe Route.UserParams User.Model User.Msg Model Msg Global.Model Global.Msg a
user =
    User.page
        { toModel = UserModel
        , toMsg = UserMsg
        }


init : Route -> Application.Init Model Msg Global.Model Global.Msg
init route_ =
    case route_ of
        Route.Account route ->
            account.init route

        Route.Notifications route ->
            notifications.init route

        Route.User route ->
            user.init route


update : Msg -> Model -> Application.Update Model Msg Global.Model Global.Msg
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


bundle : Model -> Application.Bundle Msg Global.Model Global.Msg msg
bundle model_ =
    case model_ of
        AccountModel model ->
            account.bundle model

        NotificationsModel model ->
            notifications.bundle model

        UserModel model ->
            user.bundle model

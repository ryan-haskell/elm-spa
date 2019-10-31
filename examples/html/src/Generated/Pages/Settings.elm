module Generated.Pages.Settings exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page

import Generated.Route.Settings as Route
import Html
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


account =
    Account.page
        { toModel = AccountModel
        , toMsg = AccountMsg
        , map = Html.map
        }


notifications =
    Notifications.page
        { toModel = NotificationsModel
        , toMsg = NotificationsMsg
        , map = Html.map
        }


user =
    User.page
        { toModel = UserModel
        , toMsg = UserMsg
        , map = Html.map
        }


init route_ =
    case route_ of
        Route.Account route ->
            account.init route

        Route.Notifications route ->
            notifications.init route

        Route.User route ->
            user.init route


update msg_ model_ =
    case ( msg_, model_ ) of
        ( AccountMsg msg, AccountModel model ) ->
            account.update msg model

        ( NotificationsMsg msg, NotificationsModel model ) ->
            notifications.update msg model

        ( UserMsg msg, UserModel model ) ->
            user.update msg model

        _ ->
            Page.keep model_


bundle model_ =
    case model_ of
        AccountModel model ->
            account.bundle model

        NotificationsModel model ->
            notifications.bundle model

        UserModel model ->
            user.bundle model


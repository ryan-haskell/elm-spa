module Generated.Pages.Settings exposing (Model, Msg, Params, page)

import Application
import Generated.Route.Settings as Route exposing (Route)
import Html exposing (..)
import Layouts.Settings
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


type alias Params =
    Route


page : Application.Page Params Model Msg model msg
page =
    Application.glue glue


glue : Application.Glue Route Model Msg
glue =
    { layout = Layouts.Settings.layout
    , pages = pages
    }


pages : Application.Pages Route Model Msg
pages =
    { init = init
    , update = update
    , bundle = bundle
    }


account : Application.Recipe Account.Params Account.Model Account.Msg Model Msg
account =
    Account.page
        { toModel = AccountModel
        , toMsg = AccountMsg
        }


notifications : Application.Recipe Notifications.Params Notifications.Model Notifications.Msg Model Msg
notifications =
    Notifications.page
        { toModel = NotificationsModel
        , toMsg = NotificationsMsg
        }


user : Application.Recipe User.Params User.Model User.Msg Model Msg
user =
    User.page
        { toModel = UserModel
        , toMsg = UserMsg
        }


init : Route -> ( Model, Cmd Msg )
init route =
    case route of
        Route.Account params ->
            account.init params

        Route.Notifications params ->
            notifications.init params

        Route.User params ->
            user.init params


update : Msg -> Model -> ( Model, Cmd Msg )
update appMsg appModel =
    case ( appMsg, appModel ) of
        ( AccountMsg msg, AccountModel model ) ->
            account.update msg model

        ( AccountMsg _, _ ) ->
            Application.keep appModel

        ( NotificationsMsg msg, NotificationsModel model ) ->
            notifications.update msg model

        ( NotificationsMsg _, _ ) ->
            Application.keep appModel

        ( UserMsg msg, UserModel model ) ->
            user.update msg model

        ( UserMsg _, _ ) ->
            Application.keep appModel


bundle : Model -> Application.Bundle Msg
bundle appModel =
    case appModel of
        AccountModel model ->
            account.bundle model

        NotificationsModel model ->
            notifications.bundle model

        UserModel model ->
            user.bundle model

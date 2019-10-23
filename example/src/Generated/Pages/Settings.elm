module Generated.Pages.Settings exposing
    ( Model
    , Msg
    , Params
    , page
    )

import Application
import Html exposing (..)
import Layouts.Settings
import Pages.Settings.Account as Account
import Pages.Settings.Notifications as Notifications
import Pages.Settings.User as User
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = AccountRoute Account.Params
    | NotificationsRoute Notifications.Params
    | UserRoute User.Params


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


page : Application.Page Params Model Msg route model msg
page =
    Application.glue
        { route = r
        , layout = Layouts.Settings.layout
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


r : Parser (Route -> route) route
r =
    Parser.s "settings" </> Parser.oneOf routes |> Parser.map identity


routes : Application.Routes Route
routes =
    [ account.route
    , notifications.route
    , user.route
    ]


account : Application.Recipe Account.Params Account.Model Account.Msg Route Model Msg
account =
    Account.page
        { toRoute = AccountRoute
        , toModel = AccountModel
        , toMsg = AccountMsg
        }


notifications : Application.Recipe Notifications.Params Notifications.Model Notifications.Msg Route Model Msg
notifications =
    Notifications.page
        { toRoute = NotificationsRoute
        , toModel = NotificationsModel
        , toMsg = NotificationsMsg
        }


user : Application.Recipe User.Params User.Model User.Msg Route Model Msg
user =
    User.page
        { toRoute = UserRoute
        , toModel = UserModel
        , toMsg = UserMsg
        }


init : Route -> Application.Init Model Msg
init route =
    case route of
        AccountRoute params ->
            account.init params

        NotificationsRoute params ->
            notifications.init params

        UserRoute params ->
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

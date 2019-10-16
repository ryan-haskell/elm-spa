module Pages.Settings exposing (Model, Msg)

import Pages.Settings.Account as Account
import Pages.Settings.Notifications as Notifications
import Pages.Settings.User as User



-- TODO : Export Application.layout or something for scaling this trash


type Route
    = Account
    | Notifications
    | User


type Model
    = AccountModel Account.Model
    | NotificationsModel Notifications.Model
    | UserModel User.Model


type Msg
    = AccountMsg Account.Msg
    | NotificationsMsg Notifications.Msg
    | UserMsg User.Msg

module Generated.Route.Settings exposing
    ( AccountParams
    , NotificationsParams
    , Route(..)
    , UserParams
    , routes
    , toPath
    )

import Application.Route as Route


type alias AccountParams =
    ()


type alias NotificationsParams =
    ()


type alias UserParams =
    ()


type Route
    = Account AccountParams
    | Notifications NotificationsParams
    | User UserParams


routes =
    [ Route.path "account" Account
    , Route.path "notifications" Notifications
    , Route.path "user" User
    ]


toPath route =
    case route of
        Account _ ->
            "/account"

        Notifications _ ->
            "/notifications"

        User _ ->
            "/user"

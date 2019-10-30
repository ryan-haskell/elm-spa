module Generated.Route.Settings exposing
    ( AccountParams
    , NotificationsParams
    , Route(..)
    , UserParams
    , routes
    , shouldTransition
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


routes : List (Route.Route Route)
routes =
    [ Route.path "account" Account
    , Route.path "notifications" Notifications
    , Route.path "user" User
    ]


toPath : Route -> String
toPath route =
    case route of
        Account _ ->
            "/account"

        Notifications _ ->
            "/notifications"

        User _ ->
            "/user"


shouldTransition : List String -> List String -> Bool
shouldTransition current next =
    case ( current, next ) of
        ( "settings" :: _, "settings" :: _ ) ->
            True

        _ ->
            False

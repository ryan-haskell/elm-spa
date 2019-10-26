module Generated.Route exposing
    ( CounterParams
    , IndexParams
    , NotFoundParams
    , RandomParams
    , Route(..)
    , SettingsParams
    , SignInParams
    , UsersParams
    , routes
    , toPath
    )

import Application.Route as Route
import Generated.Route.Settings as Settings
import Generated.Route.Users as Users


type alias CounterParams =
    ()


type alias IndexParams =
    ()


type alias NotFoundParams =
    ()


type alias RandomParams =
    ()


type alias SignInParams =
    ()


type alias SettingsParams =
    Settings.Route


type alias UsersParams =
    Users.Route


type Route
    = Counter CounterParams
    | Index IndexParams
    | NotFound NotFoundParams
    | Random RandomParams
    | SignIn SignInParams
    | Settings SettingsParams
    | Users UsersParams


routes : List (Route.Route Route)
routes =
    [ Route.path "counter" Counter
    , Route.index Index
    , Route.path "not-found" NotFound
    , Route.path "random" Random
    , Route.path "sign-in" SignIn
    , Route.folder "settings" Settings Settings.routes
    , Route.folder "users" Users Users.routes
    ]


toPath : Route -> String
toPath route =
    case route of
        Counter _ ->
            "/counter"

        Index _ ->
            "/"

        NotFound _ ->
            "/not-found"

        Random _ ->
            "/random"

        SignIn _ ->
            "/sign-in"

        Settings route_ ->
            "/settings" ++ Settings.toPath route_

        Users route_ ->
            "/users" ++ Users.toPath route_

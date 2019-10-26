module Generated.Route exposing
    ( CounterParams
    , IndexParams
    , NotFoundParams
    , RandomParams
    , Route(..)
    , SettingsParams
    , SignInParams
    , routes
    )

import Application.Route as Route
import Generated.Route.Settings as Settings


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


type Route
    = Counter CounterParams
    | Index IndexParams
    | NotFound NotFoundParams
    | Random RandomParams
    | SignIn SignInParams
    | Settings SettingsParams


routes : List (Route.Route Route)
routes =
    [ Route.path "counter" Counter
    , Route.index Index
    , Route.path "not-found" NotFound
    , Route.path "random" Random
    , Route.path "sign-in" SignIn
    , Route.folder "settings" Settings Settings.routes
    ]

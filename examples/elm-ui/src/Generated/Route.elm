module Generated.Route exposing
    ( IndexParams
    , NotFoundParams
    , Route(..)
    , SignInParams
    , routes
    , toPath
    )

import Application.Route as Route


type alias IndexParams =
    ()


type alias NotFoundParams =
    ()


type alias SignInParams =
    ()


type Route
    = Index IndexParams
    | NotFound NotFoundParams
    | SignIn SignInParams


routes : List (Route.Route Route)
routes =
    [ Route.index Index
    , Route.path "not-found" NotFound
    , Route.path "sign-in" SignIn
    ]


toPath : Route -> String
toPath route =
    case route of
        Index _ ->
            "/"

        NotFound _ ->
            "/not-found"

        SignIn _ ->
            "/sign-in"

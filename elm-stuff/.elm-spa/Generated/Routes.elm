module Generated.Routes exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Route as Route
import Generated.Docs.Routes
import Generated.Flags as Flags
import Generated.Guide.Routes


type Route
    = Top Flags.Top
    | Docs Flags.Docs
    | NotFound Flags.NotFound
    | SignIn Flags.SignIn
    | Guide Flags.Guide
    | Guide_Folder Generated.Guide.Routes.Route
    | Docs_Folder Generated.Docs.Routes.Route


routes : List (Route.Route Route a)
routes =
    [ Route.top Top
    , Route.path "docs" Docs
    , Route.path "not-found" NotFound
    , Route.path "sign-in" SignIn
    , Route.path "guide" Guide
    , Route.folder "guide" Guide_Folder Generated.Guide.Routes.routes
    , Route.folder "docs" Docs_Folder Generated.Docs.Routes.routes
    ]


toPath : Route -> String
toPath route =
    case route of
        Top _ ->
            "/"

        Docs _ ->
            "/docs"

        NotFound _ ->
            "/not-found"

        SignIn _ ->
            "/sign-in"

        Guide _ ->
            "/guide"

        Guide_Folder route_ ->
            "/guide" ++ Generated.Guide.Routes.toPath route_

        Docs_Folder route_ ->
            "/docs" ++ Generated.Docs.Routes.toPath route_

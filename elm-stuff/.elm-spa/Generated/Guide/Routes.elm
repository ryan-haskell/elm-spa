module Generated.Guide.Routes exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Route as Route
import Generated.Guide.Dynamic.Routes
import Generated.Guide.Flags as Flags


type Route
    = Elm Flags.Elm
    | ElmSpa Flags.ElmSpa
    | Programming Flags.Programming
    | Dynamic_Folder String Generated.Guide.Dynamic.Routes.Route


routes : List (Route.Route Route a)
routes =
    [ Route.path "elm" Elm
    , Route.path "elm-spa" ElmSpa
    , Route.path "programming" Programming
    , Route.dynamicFolder Dynamic_Folder Generated.Guide.Dynamic.Routes.routes
    ]


toPath : Route -> String
toPath route =
    case route of
        Elm _ ->
            "/"

        ElmSpa _ ->
            "/elm-spa"

        Programming _ ->
            "/programming"

        Dynamic_Folder string route_ ->
            "/" ++ string ++ Generated.Guide.Dynamic.Routes.toPath route_

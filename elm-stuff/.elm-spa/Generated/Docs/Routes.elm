module Generated.Docs.Routes exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Route as Route
import Generated.Docs.Flags as Flags


type Route
    = Static Flags.Static
    | Dynamic Flags.Dynamic


routes : List (Route.Route Route a)
routes =
    [ Route.path "static" Static
    , Route.dynamic Dynamic
    ]


toPath : Route -> String
toPath route =
    case route of
        Static _ ->
            "/static"

        Dynamic string ->
            "/" ++ string

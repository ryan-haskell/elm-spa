module Generated.Guide.Dynamic.Routes exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Route as Route
import Generated.Guide.Dynamic.Flags as Flags


type Route
    = Intro Flags.Intro


routes : List (Route.Route Route a)
routes =
    [ Route.path "intro" Intro
    ]


toPath : Route -> String
toPath route =
    case route of
        Intro _ ->
            "/intro"

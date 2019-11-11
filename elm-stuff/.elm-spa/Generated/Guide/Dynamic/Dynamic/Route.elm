module Generated.Guide.Dynamic.Dynamic.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Guide.Dynamic.Dynamic.Params as Params


type Route
    = Top Params.Top


toPath : Route -> String
toPath route =
    case route of
        Top _ ->
            "/"

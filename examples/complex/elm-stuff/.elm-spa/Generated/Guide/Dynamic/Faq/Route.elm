module Generated.Guide.Dynamic.Faq.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Guide.Dynamic.Faq.Params as Params


type Route
    = Top Params.Top


toPath : Route -> String
toPath route =
    case route of
        Top _ ->
            "/top"
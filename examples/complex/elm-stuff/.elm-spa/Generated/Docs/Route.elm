module Generated.Docs.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Docs.Params as Params


type Route
    = Static Params.Static
    | Dynamic String Params.Dynamic


toPath : Route -> String
toPath route =
    case route of
        Static _ ->
            "/static"

        Dynamic value _ ->
            "/" ++ value

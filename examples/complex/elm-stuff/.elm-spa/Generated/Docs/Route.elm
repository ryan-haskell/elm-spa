module Generated.Docs.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Docs.Params as Params


type Route
    = Dynamic String Params.Dynamic
    | Static Params.Static


toPath : Route -> String
toPath route =
    case route of
        Static _ ->
            "/static"
        
        
        Dynamic value _ ->
            "/" ++ value
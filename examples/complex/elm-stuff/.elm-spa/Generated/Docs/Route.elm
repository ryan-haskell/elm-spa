module Generated.Docs.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Docs.Params as Params


type Route
    = Dynamic String Params.Dynamic
    | Static Params.Static
    | Top Params.Top


toPath : Route -> String
toPath route =
    case route of
        Static _ ->
            "/static"
        
        
        Top _ ->
            "/"
        
        
        Dynamic value _ ->
            "/" ++ value
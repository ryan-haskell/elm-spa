module Generated.Docs.Route exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Router
import Generated.Docs.Params as Params
import Url.Parser as Parser exposing ((</>), Parser)


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


routes :
    {}
    -> List (Parser (Route -> a) a)
routes params =
    let
        router =
            App.Router.create params
    in
    [ router.path Static "static"
    , router.dynamic Dynamic (\param1 -> { param1 = param1 })
    ]

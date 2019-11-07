module Generated.Guide.Dynamic.Route exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Router
import Generated.Guide.Dynamic.Params as Params
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Intro Params.Intro
    | Other Params.Other


toPath : Route -> String
toPath route =
    case route of
        Intro _ ->
            "/intro"

        Other _ ->
            "/other"


routes :
    { param1 : String }
    -> List (Parser (Route -> a) a)
routes params =
    let
        router =
            App.Router.create params
    in
    [ router.path Intro "intro"
    , router.path Other "other"
    ]

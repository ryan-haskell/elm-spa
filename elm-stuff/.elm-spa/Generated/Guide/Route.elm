module Generated.Guide.Route exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Router
import Generated.Guide.Dynamic.Route as Dynamic_Routes
import Generated.Guide.Params as Params
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Elm Params.Elm
    | ElmSpa Params.ElmSpa
    | Programming Params.Programming
    | Dynamic_Folder String Dynamic_Routes.Route


toPath : Route -> String
toPath route =
    case route of
        Elm _ ->
            "/elm"

        ElmSpa _ ->
            "/elm-spa"

        Programming _ ->
            "/programming"

        Dynamic_Folder value subRoute ->
            "/" ++ value ++ Dynamic_Routes.toPath subRoute


routes :
    {}
    -> List (Parser (Route -> a) a)
routes params =
    let
        router =
            App.Router.create params
    in
    [ router.path Elm "elm"
    , router.path ElmSpa "elm-spa"
    , router.path Programming "programming"
    , router.dynamicFolder Dynamic_Folder
        (\param1 -> { param1 = param1 })
        Dynamic_Routes.routes
    ]

module Generated.Guide.Route exposing
    ( Route(..)
    , toPath
    )

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

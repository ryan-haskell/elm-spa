module Generated.Guide.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Guide.Params as Params
import Generated.Guide.Dynamic.Route


type Route
    = Elm Params.Elm
    | ElmSpa Params.ElmSpa
    | Programming Params.Programming
    | Dynamic_Folder String Generated.Guide.Dynamic.Route.Route


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
            "/" ++ value ++ Generated.Guide.Dynamic.Route.toPath subRoute
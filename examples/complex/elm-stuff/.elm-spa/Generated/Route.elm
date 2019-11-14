module Generated.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Params as Params
import Generated.Docs.Route
import Generated.Guide.Route


type Route
    = Docs Params.Docs
    | Guide Params.Guide
    | NotFound Params.NotFound
    | SignIn Params.SignIn
    | Top Params.Top
    | Docs_Folder Generated.Docs.Route.Route
    | Guide_Folder Generated.Guide.Route.Route


toPath : Route -> String
toPath route =
    case route of
        Docs _ ->
            "/docs"
        
        
        Guide _ ->
            "/guide"
        
        
        NotFound _ ->
            "/not-found"
        
        
        SignIn _ ->
            "/sign-in"
        
        
        Top _ ->
            "/top"
        
        
        Docs_Folder subRoute ->
            "/docs" ++ Generated.Docs.Route.toPath subRoute
        
        
        Guide_Folder subRoute ->
            "/guide" ++ Generated.Guide.Route.toPath subRoute
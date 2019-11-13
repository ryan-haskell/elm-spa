module Generated.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Docs.Route
import Generated.Guide.Route
import Generated.Params


type Route
    = Top Generated.Params.Top
    | Docs Generated.Params.Docs
    | NotFound Generated.Params.NotFound
    | SignIn Generated.Params.SignIn
    | Guide Generated.Params.Guide
    | Guide_Folder Generated.Guide.Route.Route
    | Docs_Folder Generated.Docs.Route.Route


toPath : Route -> String
toPath route =
    case route of
        Top _ ->
            "/"

        Docs _ ->
            "/docs"

        NotFound _ ->
            "/not-found"

        SignIn _ ->
            "/sign-in"

        Guide _ ->
            "/guide"

        Guide_Folder subRoute ->
            "/guide" ++ Generated.Guide.Route.toPath subRoute

        Docs_Folder subRoute ->
            "/docs" ++ Generated.Docs.Route.toPath subRoute

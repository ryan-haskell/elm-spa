module Generated.Route exposing
    ( Route(..)
    , routes
    , toPath
    )

import App.Router
import Generated.Docs.Route
import Generated.Guide.Dynamic.Route
import Generated.Guide.Route
import Generated.Params
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Top Generated.Params.Top
    | Docs Generated.Params.Docs
    | NotFound Generated.Params.NotFound
    | SignIn Generated.Params.SignIn
    | Guide Generated.Params.Guide
    | Guide_Folder Generated.Guide.Route.Route
    | Docs_Folder Generated.Docs.Route.Route


routes : List (Parser (Route -> a) a)
routes =
    let
        router =
            App.Router.create {}
    in
    [ router.top Top
    , router.path Docs "docs"
    , router.path Guide "guide"
    , router.path SignIn "sign-in"
    , router.path NotFound "not-found"
    , router.folder Guide_Folder "guide" Generated.Guide.Route.routes
    , router.folder Docs_Folder "docs" Generated.Docs.Route.routes
    ]


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

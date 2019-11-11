module Generated.Route exposing
    ( Route(..)
    , routes
    , toPath
    )

import Generated.Docs.Route
import Generated.Guide.Dynamic.Dynamic.Route
import Generated.Guide.Dynamic.Faq.Route
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
    [ Parser.top
        |> Parser.map (Top {})
    , Parser.s "docs"
        |> Parser.map (Docs {})
    , Parser.s "guide"
        |> Parser.map (Guide {})
    , Parser.s "not-found"
        |> Parser.map (NotFound {})
    , Parser.s "sign-in"
        |> Parser.map (SignIn {})
    , Parser.s "guide"
        </> Parser.s "elm"
        |> Parser.map (Guide_Folder (Generated.Guide.Route.Elm {}))
    , Parser.s "guide"
        </> Parser.s "elm-spa"
        |> Parser.map (Guide_Folder (Generated.Guide.Route.ElmSpa {}))
    , Parser.s "guide"
        </> Parser.s "programming"
        |> Parser.map (Guide_Folder (Generated.Guide.Route.Programming {}))
    , Parser.s "guide"
        </> Parser.string
        </> Parser.s "intro"
        |> Parser.map
            (\param1 ->
                Guide_Folder
                    (Generated.Guide.Route.Dynamic_Folder
                        param1
                        (Generated.Guide.Dynamic.Route.Intro { param1 = param1 })
                    )
            )
    , Parser.s "guide"
        </> Parser.string
        </> Parser.s "other"
        |> Parser.map
            (\param1 ->
                Guide_Folder
                    (Generated.Guide.Route.Dynamic_Folder
                        param1
                        (Generated.Guide.Dynamic.Route.Other { param1 = param1 })
                    )
            )
    , Parser.s "guide"
        </> Parser.string
        </> Parser.s "faq"
        </> Parser.top
        |> Parser.map
            (\param1 ->
                Guide_Folder <|
                    Generated.Guide.Route.Dynamic_Folder param1 <|
                        Generated.Guide.Dynamic.Route.Faq_Folder <|
                            Generated.Guide.Dynamic.Faq.Route.Top { param1 = param1 }
            )
    , Parser.s "guide"
        </> Parser.string
        </> Parser.string
        </> Parser.top
        |> Parser.map
            (\param1 param2 ->
                Guide_Folder <|
                    Generated.Guide.Route.Dynamic_Folder param1 <|
                        Generated.Guide.Dynamic.Route.Dynamic_Folder param2 <|
                            Generated.Guide.Dynamic.Dynamic.Route.Top { param1 = param1, param2 = param2 }
            )
    , Parser.s "docs"
        </> Parser.s "static"
        |> Parser.map (Docs_Folder (Generated.Docs.Route.Static {}))
    , Parser.s "docs"
        </> Parser.string
        |> Parser.map
            (\param1 ->
                Docs_Folder <|
                    Generated.Docs.Route.Dynamic param1 { param1 = param1 }
            )
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

module Generated.Guide.Dynamic.Route exposing
    ( Route(..)
    , toPath
    )

import Generated.Guide.Dynamic.Dynamic.Route
import Generated.Guide.Dynamic.Faq.Route
import Generated.Guide.Dynamic.Params as Params
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Intro Params.Intro
    | Other Params.Other
    | Dynamic String Params.Dynamic
    | Faq_Folder Generated.Guide.Dynamic.Faq.Route.Route
    | Dynamic_Folder String Generated.Guide.Dynamic.Dynamic.Route.Route


toPath : Route -> String
toPath route =
    case route of
        Intro _ ->
            "/intro"

        Other _ ->
            "/other"

        Dynamic value _ ->
            "/" ++ value

        Faq_Folder subRoute ->
            "/faq" ++ Generated.Guide.Dynamic.Faq.Route.toPath subRoute

        Dynamic_Folder value subRoute ->
            "/" ++ value ++ Generated.Guide.Dynamic.Dynamic.Route.toPath subRoute

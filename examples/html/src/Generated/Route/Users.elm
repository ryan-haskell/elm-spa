module Generated.Route.Users exposing
    ( Route(..)
    , SlugParams
    , routes
    , toPath
    )

import Application.Route as Route


type alias SlugParams =
    String


type Route
    = Slug SlugParams


routes =
    [ Route.slug Slug
    ]


toPath route =
    case route of
        Slug slug ->
            "/" ++ slug

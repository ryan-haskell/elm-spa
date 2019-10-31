module Generated.Route.Users exposing
    ( Route(..)
    , routes
    , toPath
    , SlugParams
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
        Slug _ ->
            "/slug"


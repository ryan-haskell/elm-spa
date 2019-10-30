module Generated.Route.Users exposing
    ( Route(..)
    , SlugParams
    , routes
    , shouldTransition
    , toPath
    )

import Application.Route as Route


type alias SlugParams =
    String


type Route
    = Slug SlugParams


routes : List (Route.Route Route)
routes =
    [ Route.slug Slug
    ]


toPath : Route -> String
toPath route =
    case route of
        Slug slug ->
            "/" ++ slug


shouldTransition : List String -> List String -> Bool
shouldTransition current next =
    case ( current, next ) of
        ( "users" :: _, "users" :: _ ) ->
            True

        _ ->
            False

module Generated.Route exposing
    ( Route(..)
    , routes
    , toPath
    , IndexParams
    , NotFoundParams
    , SomePageParams
    )


import Application.Route as Route



type alias IndexParams =
    ()


type alias NotFoundParams =
    ()


type alias SomePageParams =
    ()




 
type Route
    = Index IndexParams
    | NotFound NotFoundParams
    | SomePage SomePageParams


routes =
    [ Route.index Index
    , Route.path "not-found" NotFound
    , Route.path "some-page" SomePage
    ]


toPath route =
    case route of
        Index _ ->
            "/"

        NotFound _ ->
            "/not-found"

        SomePage _ ->
            "/some-page"


module Application.Route exposing (Route, folder, index, path, slug)

import Internals.Route as Route


type alias Route route =
    Route.Route route


index : (() -> route) -> Route route
index =
    Route.index


slug : (String -> route) -> Route route
slug =
    Route.slug


path : String -> (() -> route) -> Route route
path =
    Route.path


folder : String -> (a -> route) -> List (Route a) -> Route route
folder =
    Route.folder

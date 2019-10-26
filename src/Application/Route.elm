module Application.Route exposing
    ( Route
    , folder
    , index
    , path
    , slug
    )

import Url.Parser as Parser exposing ((</>), Parser)


type alias Route route =
    Parser (route -> route) route


index : (() -> route) -> Route route
index toRoute =
    Parser.map toRoute (Parser.top |> Parser.map ())


slug : (String -> route) -> Route route
slug toRoute =
    Parser.map toRoute Parser.string


path : String -> (() -> route) -> Route route
path p toRoute =
    Parser.map toRoute (Parser.s p |> Parser.map ())


folder : String -> (a -> route) -> List (Route a) -> Route route
folder p toRoute children =
    Parser.map toRoute
        (Parser.s p </> Parser.oneOf children |> Parser.map identity)

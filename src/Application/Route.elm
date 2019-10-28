module Application.Route exposing
    ( Route
    , folder
    , index
    , path
    , slug
    )

import Url.Parser as Parser exposing ((</>), Parser)


type alias Route route =
    { label : String
    , parser : Parser (route -> route) route
    , shouldTransition : Maybe (List String -> List String -> Bool)
    }


index : (() -> route) -> Route route
index toRoute =
    Route
        "index"
        (Parser.map toRoute (Parser.top |> Parser.map ()))
        Nothing


slug : (String -> route) -> Route route
slug toRoute =
    Route
        "slug"
        (Parser.map toRoute Parser.string)
        Nothing


path : String -> (() -> route) -> Route route
path p toRoute =
    Route
        p
        (Parser.map toRoute (Parser.s p |> Parser.map ()))
        Nothing


folder :
    String
    -> (a -> route)
    -> List (Route a)
    -> (List String -> List String -> Bool)
    -> Route route
folder p toRoute children shouldTransition =
    Route
        p
        (Parser.map toRoute
            (Parser.s p </> Parser.oneOf (List.map .parser children) |> Parser.map identity)
        )
        (Just shouldTransition)

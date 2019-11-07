module App.Router exposing (Router, create)

import Url.Parser as Parser exposing ((</>), Parser)


router =
    { top =
        \r -> Parser.map (r {}) <| Parser.top
    , path =
        \r p -> Parser.map (r {}) <| Parser.s p
    , folder =
        \r p children -> Parser.map r <| Parser.s p </> Parser.oneOf children
    , dynamicFolder =
        \folder toParams routes_ ->
            Parser.string
                |> andThen
                    (\value ->
                        Parser.oneOf (routes_ (toParams value))
                            |> Parser.map (folder value)
                    )
    }


andThen :
    (a -> Parser (b -> c) c)
    -> Parser (a -> b) b
    -> Parser (b -> c) c
andThen =
    Debug.todo "Parser.andThen"


type alias Router params subParams route subRoute a =
    { top :
        (params -> route)
        -> Parser (route -> a) a
    , path :
        (params -> route)
        -> String
        -> Parser (route -> a) a
    , dynamic :
        (String -> subParams -> route)
        -> (String -> subParams)
        -> Parser (route -> a) a
    , folder :
        (subRoute -> route)
        -> String
        -> (params -> List (Parser (subRoute -> route) route))
        -> Parser (route -> a) a
    , dynamicFolder :
        (String -> subRoute -> route)
        -> (String -> subParams)
        -> (subParams -> List (Parser (subRoute -> route) route))
        -> Parser (route -> a) a
    }


create : params -> Router params subParams route subRoute a
create params =
    { top =
        \toRoute ->
            Parser.map (toRoute params)
                Parser.top
    , path =
        \toRoute path ->
            Parser.map (toRoute params)
                (Parser.s path)
    , dynamic =
        \toRoute toParams ->
            Parser.map (\value -> toRoute value (toParams value))
                Parser.string
    , folder =
        \toRoute path children ->
            Parser.map toRoute
                (Parser.s path </> Parser.oneOf (children params))
    , dynamicFolder =
        \toRoute toParams routes_ ->
            Parser.string
                |> andThen
                    (\value ->
                        Parser.oneOf (routes_ (toParams value))
                            |> Parser.map (toRoute value)
                    )
    }

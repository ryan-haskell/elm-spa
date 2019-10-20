module Generated.Route.Settings exposing
    ( Route(..)
    , parser
    , toPath
    )

import Url.Parser as Parser exposing (Parser)


type Route
    = Account ()
    | Notifications ()
    | User ()


toPath : Route -> String
toPath route =
    case route of
        Account _ ->
            "/account"

        Notifications _ ->
            "/notifications"

        User _ ->
            "/user"


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.s "account"
            |> Parser.map (Account ())
        , Parser.s "notifications"
            |> Parser.map (Notifications ())
        , Parser.s "user"
            |> Parser.map (User ())
        ]

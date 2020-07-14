module Api.Token exposing
    ( Token
    , fromString
    , toString
    )


type Token
    = Token String


fromString : String -> Token
fromString =
    Token


toString : Token -> String
toString (Token token) =
    token

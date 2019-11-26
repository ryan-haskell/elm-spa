module Utils.Markdown exposing
    ( Markdown(..)
    , parse
    , parser
    )

import Json.Decode as Json
import Json.Encode
import Parser exposing ((|.), (|=), Parser)


type Markdown frontmatter
    = WithFrontmatter
        { frontmatter : frontmatter
        , content : String
        }
    | WithoutFrontmatter String


parse : Json.Decoder a -> String -> Markdown a
parse decoder value =
    value
        |> Parser.run parser
        |> Result.mapError (\_ -> Json.Failure "Could not parse markdown." Json.Encode.null)
        |> Result.andThen
            (\raw ->
                raw.frontmatter
                    |> Json.decodeString decoder
                    |> Result.map
                        (\frontmatter ->
                            WithFrontmatter
                                { frontmatter = frontmatter
                                , content = raw.content
                                }
                        )
                    |> Result.withDefault (WithoutFrontmatter raw.content)
                    |> Ok
            )
        |> Result.withDefault (WithoutFrontmatter value)


type alias RawMarkdown =
    { frontmatter : String
    , content : String
    }


parser : Parser RawMarkdown
parser =
    Parser.succeed RawMarkdown
        |. Parser.symbol "---"
        |= frontmatterParser
        |. Parser.symbol "---"
        |= contentParser


frontmatterParser : Parser String
frontmatterParser =
    Parser.getChompedString <|
        Parser.chompUntil "---"


contentParser : Parser String
contentParser =
    Parser.getChompedString <|
        Parser.chompWhile (always True)

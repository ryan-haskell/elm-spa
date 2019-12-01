module Utils.Markdown exposing
    ( Frontmatter
    , Markdown(..)
    , frontmatterDecoder
    , parse
    , parser
    )

import Json.Decode as Json exposing (Decoder)
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
    let
        frontmatterParser : Parser String
        frontmatterParser =
            Parser.getChompedString <|
                Parser.chompUntil "---"

        contentParser : Parser String
        contentParser =
            Parser.getChompedString <|
                Parser.chompWhile (always True)
    in
    Parser.succeed RawMarkdown
        |. Parser.symbol "---"
        |= frontmatterParser
        |. Parser.symbol "---"
        |= contentParser



-- FRONTMATTER


type alias Frontmatter =
    { title : String
    , description : Maybe String
    }


frontmatterDecoder : Decoder Frontmatter
frontmatterDecoder =
    Json.map2 Frontmatter
        (Json.field "title" Json.string)
        (Json.field "description" (Json.nullable Json.string))

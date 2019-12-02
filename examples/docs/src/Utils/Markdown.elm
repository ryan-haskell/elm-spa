module Utils.Markdown exposing
    ( Frontmatter
    , Markdown
    , frontmatterDecoder
    , parse
    , parser
    )

import Json.Decode as Json exposing (Decoder)
import Json.Encode
import Parser exposing ((|.), (|=), Parser)


type alias Markdown frontmatter =
    { frontmatter : frontmatter
    , content : String
    }


parse : Json.Decoder a -> String -> Result Json.Error (Markdown a)
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
                            { frontmatter = frontmatter
                            , content = raw.content
                            }
                        )
            )


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
        (Json.maybe (Json.field "description" Json.string))

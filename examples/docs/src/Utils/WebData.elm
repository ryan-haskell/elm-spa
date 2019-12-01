module Utils.WebData exposing
    ( WebData(..)
    , expectMarkdown
    , fromResult
    )

import Http
import Utils.Markdown as Markdown exposing (Markdown)


type WebData a
    = Loading
    | Success a
    | Failure Http.Error


fromResult : Result Http.Error a -> WebData a
fromResult result =
    case result of
        Ok value ->
            Success value

        Err reason ->
            Failure reason


expectMarkdown :
    (WebData (Markdown Markdown.Frontmatter) -> msg)
    -> Http.Expect msg
expectMarkdown msg =
    Http.expectString
        (Result.map (Markdown.parse Markdown.frontmatterDecoder)
            >> fromResult
            >> msg
        )

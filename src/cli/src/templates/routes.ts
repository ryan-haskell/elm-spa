import { routeTypeDefinition, indent, routeParserList, paramsImports, Options } from "./utils"

export default (pages : string[][], _options : Options) : string => `
module Gen.Route exposing
    ( Route(..)
    , fromUrl
    -- , toUrl
    )

${paramsImports(pages)}
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


${routeTypeDefinition(pages)}


fromUrl : Url -> Route
fromUrl =
    Parser.parse (Parser.oneOf routes) >> Maybe.withDefault NotFound


routes : List (Parser (Route -> a) a)
routes =
${indent(routeParserList(pages), 1)}


-- toUrl : Route -> Url
-- toUrl route =
--     Debug.todo "Gen.Route.toUrl"

`.trimLeft()
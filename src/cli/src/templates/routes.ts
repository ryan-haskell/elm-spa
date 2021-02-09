import { routeTypeDefinition, indent, routeParserList, paramsImports, Options, routeToHref } from "./utils"

export default (pages : string[][], _options : Options) : string => `
module Gen.Route exposing
    ( Route(..)
    , fromUrl
    , toHref
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


toHref : Route -> String
toHref route =
    let
        joinAsHref : List String -> String
        joinAsHref segments =
            "/" ++ String.join "/" segments
    in
${indent(routeToHref(pages), 1)}

`.trimLeft()
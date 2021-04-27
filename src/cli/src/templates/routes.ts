import config from "../config"
import { routeTypeDefinition, indent, routeParserList, paramsImports, Options, routeToHref } from "./utils"

const routeParserOrder = (pages: string[][]) =>
    [...pages].sort(sorter)

const isHomepage = (list: string[]) => list.join('.') === config.reserved.homepage
const isDynamic = (piece: string) => piece.endsWith('_')
const alphaSorter = (a: string, b: string) => a < b ? -1 : b < a ? 1 : 0

const sorter = (a: string[], b: string[]): (-1 | 1 | 0) => {
    if (isHomepage(a)) return -1
    if (isHomepage(b)) return 1

    if (a.length < b.length) return -1
    if (a.length > b.length) return 1

    for (let i in a) {
        const [isA, isB] = [isDynamic(a[i]), isDynamic(b[i])]
        if (isA && isB) return alphaSorter(a[i], b[i])
        if (isA) return 1
        if (isB) return -1
    }

    return 0
}

export default (pages: string[][], _options: Options): string => `
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
${indent(routeParserList(routeParserOrder(pages)), 1)}


toHref : Route -> String
toHref route =
    let
        joinAsHref : List String -> String
        joinAsHref segments =
            "/" ++ String.join "/" segments
    in
${indent(routeToHref(pages), 1)}

`.trimLeft()
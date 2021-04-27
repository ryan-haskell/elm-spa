import { Options, routeParameters, routeParser } from "./utils"

export default (page : string[], options : Options) : string => `
module Gen.Params.${page.join('.')} exposing (Params, parser)

import Url.Parser as Parser exposing ((</>), Parser)


type alias Params =
    ${routeParameters(page)}


parser =
    ${routeParser(page)}

`.trimLeft()
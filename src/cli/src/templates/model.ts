import config from "../config"
import {
  pagesImports, paramsImports,
  pagesModelDefinition,
  Options
} from "./utils"

export default (pages : string[][], options : Options) : string => `
module Gen.Model exposing (Model(..))

${paramsImports(pages)}
${pagesImports(pages)}


${pagesModelDefinition([ [ config.reserved.redirecting ] ].concat(pages), options)}

`.trimLeft()

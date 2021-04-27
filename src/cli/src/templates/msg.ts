import {
  pagesImports, paramsImports,
  pagesMsgDefinition,
  Options,
} from "./utils"

export default (pages : string[][], options : Options) : string => `
module Gen.Msg exposing (Msg(..))

${paramsImports(pages)}
${pagesImports(pages)}


${pagesMsgDefinition(pages.filter(path => !options.isStaticView(path)), options)}

`.trimLeft()

import config from "../config"


export type PageKind = 'view' | 'static-page' | 'page'

export type Options = {
  kind: (path: string[]) => PageKind
  isStaticView: (path: string[]) => boolean
  isStaticPage: (path: string[]) => boolean
  isStandardPage: (path: string[]) => boolean
}

export const options = (kind: (path: string[]) => PageKind) : Options => ({
  kind,
  isStaticView: p => kind(p) === 'view',
  isStaticPage: p => kind(p) === 'static-page',
  isStandardPage: p => kind(p) === 'page',
})

// [ 'Home_' ] => true
const isHomepage = (path: string[]) =>
  path.join('') === config.reserved.homepage

// [ 'NotFound' ] => true
const isNotFoundPage = (path: string[]) =>
  path.join('') === config.reserved.notFound

// [ 'Users', 'Name_', 'Settings' ] => [ 'Name' ]
const dynamicRouteSegments = (path : string[]) : string[] =>
  isHomepage(path) || isNotFoundPage(path)
    ? []
    : path.filter(isDynamicSegment)
        .map(segment => segment.substr(0, segment.length - 1))

const isDynamicSegment = (segment : string) : boolean =>
  segment !== config.reserved.homepage
  && segment !== config.reserved.notFound
  && segment.endsWith('_')

// "AboutUs" => "aboutUs"
const fromPascalToCamelCase = (str : string) : string =>
  str[0].toLowerCase() + str.substring(1)

// "AboutUs" => "about-us"
const fromPascalToSlugCase = (str : string) =>
  str.split('').map((c, i) => i === 0 || c === c.toLowerCase() ? c : `-${c}`).join('').toLowerCase()

// "about-us" => "AboutUs"
const fromSlugToPascalCase = (str : string) =>
  str.split('-').map(c => c[0].toUpperCase() + c.substring(1)).join('')

// "/about-us" => [ "AboutUs" ]
// "Pages.AboutUs" => [ "AboutUs" ]
// "Pages/AboutUs.elm" => [ "AboutUs" ]
export const urlArgumentToPages = (url : string) : string[] => {
  // Cleanup common mistakes
  if (url.endsWith('.elm')) { url = url.split('.elm').join('') }
  if (url.startsWith('Pages')) { url = url.substring('Pages'.length) }

  return url === '/'
    ? [ config.reserved.homepage ]
    : url.split('/')
        .map(str => str.split('.'))
        .reduce((a, b) => a.concat(b))
        .filter(a => a).map(seg => seg.startsWith(':') ? seg.slice(1) + '_' : seg)
        .map(fromSlugToPascalCase)
}

// [ "Settings", "Notifications" ] => "Settings__Notifications"
export const routeVariant = (path : string[]) : string =>
  path.join('__')

// General Elm things
export const multilineList = (items : string[]) : string =>
  items.length === 0
    ? `[]`
    : `[ ${items.join('\n, ')}\n]`

export const multilineRecord = (sep : ':' | '=', items: [string, string][]) : string =>
  items.length === 0
    ? `{}`
    : `{ ${items.map(([k, v]) => `${k} ${sep} ${v}`).join('\n, ')}\n}`

export const customType = (type : string, variants : string[]) : string =>
  `type ${type}\n    = ${variants.join('\n    | ')}`

export const indent = (lines : string, n : number = 1) : string =>
  lines.split('\n')
    .map(line => [...Array(n)].map(_ => `    `).join('') + line)
    .join('\n')

// Used by Gen.Route
export const routeParameters = (path : string[]) : string => {
  const dynamics = dynamicRouteSegments(path)

  if (dynamics.length === 0) {
    return `()`
  } else {
    return `{ ${dynamics.map(d => `${fromPascalToCamelCase(d)} : String`).join(', ')} }`
  }
}

const routeParameters2 = (path : string[]) : string => {
  const dynamics = dynamicRouteSegments(path)

  if (dynamics.length === 0) {
    return ``
  } else {
    return ` { ${dynamics.map(d => `${fromPascalToCamelCase(d)} : String`).join(', ')} }`
  }
}

const routeParamVariable = (path : string[]) : string =>
  (dynamicRouteSegments(path).length === 0)
    ? ``
    : ` params`

const routeParamValue = (path : string[]) : string =>
  (dynamicRouteSegments(path).length === 0)
    ? `()`
    : `params`

export const paramsRouteParserMap = (path : string[]) : string =>
  dynamicRouteSegments(path).length === 0
    ? ``
    : `Parser.map Params `

export const routeParser = (path : string[]) : string => {
  const fromPiece = (p : string) : string =>
    (p === config.reserved.homepage) ? `Parser.top`
    : p.endsWith('_') ? `Parser.string`
    : `Parser.s "${fromPascalToSlugCase(p)}"`
  return `${paramsRouteParserMap(path)}(` + path.map(fromPiece).join(' </> ') + `)`
}

export const routeParserMap = (path: string[]) : string =>
  `Parser.map ${routeVariant(path)} ${paramsModule(path)}.parser`

export const routeTypeVariant = (path : string[]) : string =>
  `${routeVariant(path)}${routeParameters2(path)}`

export const routeTypeDefinition = (paths: string[][]) : string =>
  customType(`Route`, paths.map(routeTypeVariant))

export const routeParserList = (paths: string[][]) : string =>
  multilineList(paths.map(routeParserMap))

export const routeToHref = (paths: string[][]) : string =>
  caseExpression(paths, {
    variable: 'route',
    condition: (path) => 
      (dynamicRouteSegments(path).length === 0)
        ? routeVariant(path) 
        : `${routeVariant(path)} params`,
    result: (path) => `joinAsHref ${routeToHrefSegments(path)}`
  })

export const routeToHrefSegments = (path: string[]) : string => {
  const segments = path.filter(p => p !== config.reserved.homepage)
  const hrefFragments =
    segments.map(segment => 
      isDynamicSegment(segment)
        ? `params.${fromPascalToCamelCase(segment.substring(0, segment.length - 1))}`
        : `"${fromPascalToSlugCase(segment)}"`
    )
  return hrefFragments.length === 0
    ? `[]`
    : `[ ${hrefFragments.join(', ')} ]`
}

export const paramsImports = (paths: string[][]) : string =>
  paths.map(path => `import Gen.Params.${path.join('.')}`).join('\n')

export const pagesImports = (paths: string[][]) : string =>
  paths.map(path => `import ${pageModuleName(path)}`).join('\n')

const pageModuleName = (path : string[]) : string =>
  `Pages.${path.join('.')}`

export const pagesModelDefinition = (paths : string[][], options : Options) : string =>
  customType('Model',
    paths.map(path => (() => {
      if (path[0] === config.reserved.redirecting) return config.reserved.redirecting
      
      switch (options.kind(path)) {
        case 'view': return `${modelVariant(path)} ${params(path)}`
        case 'static-page': return `${modelVariant(path)} ${params(path)} ${model(path, options)}`
        case 'page': return `${modelVariant(path)} ${params(path)} ${model(path, options)}`
      }
    })())
  )

export const pagesMsgDefinition = (paths : string[][], options: Options) : string =>
  (paths.length === 0)
      ? `type Msg = None`
      : customType('Msg', paths.map(path => `${msgVariant(path)} ${msg(path, options)}`))

export const pagesBundleAnnotation = (paths : string[][], options : Options) : string =>
  indent(multilineRecord(':',
    paths.map(path => [
      bundleName(path),
      (() => {
        switch (options.kind(path)) {
          case 'view': return `Static ${params(path)}`
          case 'static-page': return `Bundle ${params(path)} ${model(path, options)} ${msg(path, options)}`
          case `page`: return `Bundle ${params(path)} ${model(path, options)} ${msg(path, options)}`
        }
      })()
    ])
  ))

export const pagesBundleDefinition = (paths : string[][], options : Options) : string =>
  indent(multilineRecord('=',
    paths.map(path => [
      bundleName(path),
      (() => {
        switch (options.kind(path)) {
          case 'view': return `static ${pageModuleName(path)}.view Model.${modelVariant(path)}`
          case 'static-page': return `bundle ${pageModuleName(path)}.page Model.${modelVariant(path)} Msg.${msgVariant(path)}`
          case `page`: return `bundle ${pageModuleName(path)}.page Model.${modelVariant(path)} Msg.${msgVariant(path)}`
        }
      })()
    ])
  ))

const bundleName = (path : string[]) : string =>
  path.map(fromPascalToCamelCase).join('__')

const paramsModule = (path : string[]) =>
  `Gen.Params.${path.join('.')}`

const params = (path : string[]) =>
  `${paramsModule(path)}.Params`

const model = (path: string[], options : Options) : string => {
  switch (options.kind(path)) {
    case 'view': return `()`
    case 'static-page': return `()`
    case 'page': return `Pages.${path.join('.')}.Model`
  }
}

const modelVariant = (path: string[]) : string =>
  `${path.join('__')}`

const msgVariant = (path: string[]) : string =>
  `${path.join('__')}`

const msg = (path: string[], options: Options) : string =>
  options.isStandardPage(path)
    ? `Pages.${path.join('.')}.Msg`
    : `Never`

export const pagesInitBody = (paths: string[][]) : string =>
  indent(caseExpression(paths, {
    variable: 'route',
    condition: path => `Route.${routeVariant(path)}${routeParamVariable(path)}`,
    result: path => `pages.${bundleName(path)}.init ${routeParamValue(path)}`
  }))

export const pagesUpdateBody = (paths: string[][], options : Options) : string =>
  indent(caseExpression(paths, {
    variable: '( msg_, model_ )',
    condition: path => `( Msg.${msgVariant(path)} msg, ${destructuredModel(path, options)} )`,
    result: path => `pages.${bundleName(path)}.update params msg model`
  }))

export const pagesUpdateCatchAll =
`
        _ ->
            \\_ _ _ -> ( model_, Effect.none )`

export const pagesViewBody = (paths: string[][], options : Options) : string =>
  indent(caseExpressionWithRedirectingModel(`\\_ _ _ -> View.none`, paths, {
    variable: 'model_',
    condition: path => `${destructuredModel(path, options)}`,
    result: path => `pages.${bundleName(path)}.view ${pageModelArguments(path, options)}`
  }))


export const pagesSubscriptionsBody = (paths: string[][], options : Options) : string =>
  indent(caseExpressionWithRedirectingModel(`\\_ _ _ -> Sub.none`, paths, {
    variable: 'model_',
    condition: path => `${destructuredModel(path, options)}`,
    result: path => `pages.${bundleName(path)}.subscriptions ${pageModelArguments(path, options)}`
  }))

const caseExpressionWithRedirectingModel = (fallback : string, items: string[][], options : { variable : string, condition : (item: string[]) => string, result: (item: string[]) => string }) =>
  caseExpression([ [ config.reserved.redirecting ] ].concat(items), {
    variable: options.variable,
    condition: (item) => item[0] === config.reserved.redirecting
      ? `Model.${config.reserved.redirecting}`
      : options.condition(item),
    result: (item) => item[0] === config.reserved.redirecting
      ? fallback
      : options.result(item)
  })

const caseExpression = <T>(items: T[], options : { variable : string, condition : (item: T) => string, result: (item: T) => string }) =>
`case ${options.variable} of
${items.map(item => `    ${options.condition(item)} ->\n        ${options.result(item)}`).join('\n\n')}`

const destructuredModel = (path: string[], options : Options) : string => {
  switch (options.kind(path)) {
    case 'view': return `Model.${modelVariant(path)} params`
    case 'static-page': return `Model.${modelVariant(path)} params model`
    case 'page': return `Model.${modelVariant(path)} params model`
  }
}

const pageModelArguments = (path: string[], options : Options) : string => {
  switch (options.kind(path)) {
    case 'view': return `params ()`
    case 'static-page': return `params model`
    case 'page': return  `params model`
  }
}

const exposes = (value : string) => (str : string) : boolean => {
  const regex = new RegExp('^module\\s+[^\\s]+\\s+exposing\\s+\\(((?:\\.\\)|[^)])+)\\)')
  const match = (str.match(regex) || [])[1]
  if (match) {
    return match.split(',').filter(a => a).map(a => a.trim()).includes(value)
  } else {
    return false
  }
}

export const exposesModel = exposes('Model')
export const exposesMsg = (str : string) => exposes('Msg')(str) || exposes('Msg(..)')(str)
export const exposesPageFunction = exposes('page')
export const exposesViewFunction = exposes('view')

export const isStandardPage = (src : string) =>
  exposesPageFunction(src)
    && exposesModel(src)
    && exposesMsg(src)

export const isStaticPage = (src : string) =>
  exposesPageFunction(src)

export const isStaticView = (src : string) =>
  exposesViewFunction(src)

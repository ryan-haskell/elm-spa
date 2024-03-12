import path from "path"
import { exists } from "../file"
import config from '../config'
import * as File from '../file'
import { createInterface } from 'readline'
import RouteTemplate from '../templates/routes'
import PagesTemplate from '../templates/pages'
import PageTemplate from '../templates/page'
import RequestTemplate from '../templates/request'
import ModelTemplate from '../templates/model'
import MsgTemplate from '../templates/msg'
import ChildProcess from 'child_process'
import ParamsTemplate from '../templates/params'
import terser from 'terser'
import { bold, underline, colors, reset, check, dim, dot, warn, error } from "../terminal"
import { isStandardPage, isStaticPage, isStaticView, options, PageKind } from "../templates/utils"
import { createMissingAddTemplates } from "./_common"
const elm = require('node-elm-compiler')

export const build = ({ env, runElmMake }: { env: Environment, runElmMake: boolean }) => () =>
  Promise.all([
    createMissingDefaultFiles(),
    createMissingAddTemplates()
  ])
    .then(createGeneratedFiles)
    .then(runElmMake ? compileMainElm(env) : _ => `  ${check} ${bold}elm-spa${reset} generated new files.`)

const createMissingDefaultFiles = async () => {
  type Action
    = ['DELETE_FROM_DEFAULTS', string[]]
    | ['CREATE_IN_DEFAULTS', string[]]
    | ['DO_NOTHING', string[]]

  const toAction = async (filepath: string[]): Promise<Action> => {
    const [inDefaults, inSrc] = await Promise.all([
      exists(path.join(config.folders.defaults.dest, ...filepath)),
      exists(path.join(config.folders.src, ...filepath))
    ])

    if (inSrc && inDefaults) {
      return ['DELETE_FROM_DEFAULTS', filepath]
    } else if (!inSrc) {
      return ['CREATE_IN_DEFAULTS', filepath]
    } else {
      return ['DO_NOTHING', filepath]
    }
  }

  const actions = await Promise.all(config.defaults.map(toAction))

  const performDefaultFileAction = ([action, relative]: Action): Promise<any> =>
    action === 'CREATE_IN_DEFAULTS' ? createDefaultFile(relative)
      : action === 'DELETE_FROM_DEFAULTS' ? deleteFromDefaults(relative)
        : Promise.resolve()

  const createDefaultFile = async (relative: string[]) =>
    File.copyFile(
      path.join(config.folders.defaults.src, ...relative),
      path.join(config.folders.defaults.dest, ...relative)
    )

  const deleteFromDefaults = async (relative: string[]) =>
    File.remove(path.join(config.folders.defaults.dest, ...relative))

  return Promise.all(actions.map(performDefaultFileAction))
}

type FilepathSegments = {
  kind: PageKind,
  entry: PageEntry
}

const getFilepathSegments = async (entries: PageEntry[]): Promise<FilepathSegments[]> => {
  const contents = await Promise.all(entries.map(e => File.read(e.filepath)))

  return Promise.all(entries.map(async (entry, i) => {
    const c = contents[i]
    const kind: PageKind = await (
      isStandardPage(c) ? Promise.resolve('page')
        : isStaticPage(c) ? Promise.resolve('static-page')
          : isStaticView(c) ? Promise.resolve('view')
            : Promise.reject(invalidExportsMessage(entry))
    )
    return { kind, entry }
  }))
}

const invalidExportsMessage = (entry: PageEntry) => {
  const moduleName = `${bold}Pages.${entry.segments.join('.')}${reset}`
  const cyan = (str: string) => `${colors.cyan}${str}${reset}`

  return [
    `${colors.RED}!${reset} Ran into a problem at ${bold}${colors.yellow}src/Pages/${entry.segments.join('/')}.elm${reset}`,
    ``,
    `${bold}elm-spa${reset} expected one of these module definitions:`,
    ``,
    `  ${dot} module ${moduleName} exposing (${cyan('view')})`,
    `  ${dot} module ${moduleName} exposing (${cyan('page')})`,
    `  ${dot} module ${moduleName} exposing (${cyan('Model')}, ${cyan('Msg')}, ${cyan('page')})`,
    ``,
    `Visit ${colors.green}https://elm-spa.dev/guide/03-pages${reset} for more details!`
  ].join('\n')
}

const createGeneratedFiles = async () => {
  const entries = await getAllPageEntries()
  const segments = entries.map(e => e.segments)

  const filepathSegments = await getFilepathSegments(entries)
  const kindForPage = (p: string[]): PageKind =>
    filepathSegments
      .filter(item => item.entry.segments.join('.') == p.join('.'))
      .map(fps => fps.kind)[0] || 'page'

  const paramFiles = segments.map(filepath => ({
    filepath: ['Gen', 'Params', ...filepath],
    contents: ParamsTemplate(filepath, options(kindForPage))
  }))

  const filesToCreate = [
    ...paramFiles,
    { filepath: ['Page'], contents: PageTemplate() },
    { filepath: ['Request'], contents: RequestTemplate() },
    { filepath: ['Gen', 'Route'], contents: RouteTemplate(segments, options(kindForPage)) },
    { filepath: ['Gen', 'Pages'], contents: PagesTemplate(segments, options(kindForPage)) },
    { filepath: ['Gen', 'Model'], contents: ModelTemplate(segments, options(kindForPage)) },
    { filepath: ['Gen', 'Msg'], contents: MsgTemplate(segments, options(kindForPage)) }
  ]

  return Promise.all(filesToCreate.map(({ filepath, contents }) =>
    File.create(path.join(config.folders.generated, ...filepath) + '.elm', contents))
  )
}

type PageEntry = {
  filepath: string;
  segments: string[];
}

const getAllPageEntries = async (): Promise<PageEntry[]> => {
  const scanPageFilesIn = async (folder: string) => {
    const items = await File.scan(folder)
    return items.map(s => ({
      filepath: s,
      segments: s.substring(folder.length + 1, s.length - '.elm'.length).split(path.sep)
    }))
  }

  return Promise.all([
    scanPageFilesIn(config.folders.pages.src),
    scanPageFilesIn(config.folders.pages.defaults)
  ]).then(([left, right]) => left.concat(right))
}

type Environment = 'production' | 'development'

const outputFilepath = path.join(config.folders.dist, 'elm.js')

const compileMainElm = (env: Environment) => async () => {
  await ensureElmIsInstalled(env)

  const start = Date.now()

  const elmMake = async () => {
    const inDevelopment = env === 'development'
    const inProduction = env === 'production'

    const isSrcMainElmDefined = await File.exists(path.join(config.folders.src, 'Main.elm'))
    const inputFilepath = isSrcMainElmDefined
      ? path.join(config.folders.src, 'Main.elm')
      : path.join(config.folders.defaults.dest, 'Main.elm')

    return elm.compileToString(inputFilepath, {
      output: outputFilepath,
      report: 'json',
      debug: inDevelopment,
      optimize: inProduction,
    })
      .catch((error: Error) => {
        try { return colorElmError(JSON.parse(error.message.split('\n')[1])) }
        catch {
          const { RED, green } = colors
          return Promise.reject([
            `${RED}!${reset} elm-spa failed to understand an error`,
            `Please report the output below to ${green}https://github.com/ryan-haskell/elm-spa/issues${reset}`,
            `-----`,
            JSON.stringify(error, null, 2),
            `-----`,
            `${RED}!${reset} elm-spa failed to understand an error`,
            `Please send the output above to ${green}https://github.com/ryan-haskell/elm-spa/issues${reset}`,
            ``
          ].join('\n\n'))
        }
      })
  }

  type ElmError
    = ElmCompileError
    | ElmJsonError

  type ElmCompileError = {
    type: 'compile-errors'
    errors: ElmProblemError[]
  }

  type ElmJsonError = Problem & {
    type: 'error',
    path: string,
  }

  type ElmProblemError = {
    path: string
    problems: Problem[]
  }

  type Problem = {
    title: string
    message: (Message | string)[]
  }

  type Message = {
    bold: boolean
    underline: boolean
    color: keyof typeof colors
    string: string
  }

  const colorElmError = (output: ElmError) => {
    const errors: ElmProblemError[] =
      output.type === 'compile-errors'
        ? output.errors
        : [{ path: output.path, problems: [output] }]

    const strIf = (str: string) => (cond: boolean): string => cond ? str : ''
    const boldIf = strIf(bold)
    const underlineIf = strIf(underline)

    const repeat = (str: string, num: number, min = 3) => [...Array(num < 0 ? min : num)].map(_ => str).join('')

    const errorToString = (error: ElmProblemError): string => {
      const problemToString = (problem: Problem): string => {
        const path = error.path.substr(process.cwd().length + 1)
        return [
          `${colors.cyan}-- ${problem.title} ${repeat('-', 63 - problem.title.length - path.length)} ${path}${reset}`,
          problem.message.map(messageToString).join('')
        ].join('\n\n')
      }

      const messageToString = (line: Message | string) =>
        typeof line === 'string'
          ? line
          : [boldIf(line.bold), underlineIf(line.underline), colors[line.color] || '', line.string, reset].join('')

      return error.problems.map(problemToString).join('\n\n')
    }

    return Promise.reject(errors.map(err => errorToString(err)).join('\n\n\n'))
  }

  const success = () => `${check} Build successful! ${dim}(${Date.now() - start}ms)${reset}`

  const minify = (rawCode: string) =>
    terser.minify(rawCode, { compress: { pure_funcs: `F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9`.split(','), pure_getters: true, keep_fargs: false, unsafe_comps: true, unsafe: true } })
      .then(intermediate => terser.minify(intermediate.code || '', { mangle: true }))
      .then(minified => File.create(outputFilepath, minified.code || ''))

  return (env === 'development')
    ? elmMake()
      .then(rawJsCode => File.create(outputFilepath, rawJsCode))
      .then(_ => success())
      .catch(error => error)
    : elmMake()
      .then(minify)
      .then(_ => [success() + '\n'])
}

const ensureElmIsInstalled = async (environment: Environment) => {
  await new Promise((resolve, reject) => {
    ChildProcess.exec('elm', (err) => {
      if (err) {
        if (environment === 'production') {
          attemptToInstallViaNpm(resolve, reject)
        } else {
          offerToInstallForDeveloper(resolve, reject)
        }
      } else {
        resolve(undefined)
      }
    })
  })
}

const attemptToInstallViaNpm = (resolve: (value: unknown) => void, reject: (reason: unknown) => void) => {
  process.stdout.write(`\n  ${bold}Awesome!${reset} Installing Elm via NPM... `)
  ChildProcess.exec(`npm install --global elm@latest-0.19.1`, (err) => {
    if (err) {
      console.info(error)
      reject(`  The automatic install didn't work...\n  Please visit ${colors.green}https://guide.elm-lang.org/install/elm${reset} to install Elm.\n`)
    } else {
      console.info(check)
      console.info(`  Elm is now installed!`)
      resolve(undefined)
    }
  })
}

const offerToInstallForDeveloper = (resolve: (value: unknown) => void, reject: (reason: unknown) => void) => {
  const rl = createInterface({
    input: process.stdin,
    output: process.stdout
  })

  rl.question(`\n${warn} Elm hasn't been installed yet.\n\n  May I ${colors.cyan}install${reset} it for you? ${dim}[y/n]${reset} `, answer => {
    if (answer.toLowerCase() === 'n') {
      reject(`  ${bold}No changes made!${reset}\n  Please visit ${colors.green}https://guide.elm-lang.org/install/elm${reset} to install Elm.`)
    } else {
      attemptToInstallViaNpm(resolve, reject)
    }
  })
}

export default {
  build: build({ env: 'production', runElmMake: true }),
  gen: build({ env: 'production', runElmMake: false })
}
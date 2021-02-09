import path from "path"
import { exists } from "../file"
import config from '../config'
import * as File from '../file'
import RouteTemplate from '../templates/routes'
import PagesTemplate from '../templates/pages'
import ModelTemplate from '../templates/model'
import MsgTemplate from '../templates/msg'
import ParamsTemplate from '../templates/params'
import * as Process from '../process'
import { bold, underline, colors, reset, check, dim } from "../terminal"
import { isStaticPage } from "../templates/utils"
import { createMissingAddTemplates } from "./_common"

export const build = (env : Environment) => () =>
  Promise.all([
    createMissingDefaultFiles(),
    createMissingAddTemplates()
  ])
    .then(createGeneratedFiles)
    .then(compileMainElm(env))

const createMissingDefaultFiles = async () => {
  type Action
    = [ 'DELETE_FROM_DEFAULTS', string[] ]
    | [ 'CREATE_IN_DEFAULTS', string[] ]
    | [ 'DO_NOTHING', string[] ]

  const toAction = async (filepath : string[]) : Promise<Action> => {
    const [ inDefaults, inSrc ] = await Promise.all([
      exists(path.join(config.folders.defaults.dest, ...filepath)),
      exists(path.join(config.folders.src, ...filepath))
    ])

    if (inSrc && inDefaults) {
      return [ 'DELETE_FROM_DEFAULTS', filepath ]
    } else if (!inSrc) {
      return [ 'CREATE_IN_DEFAULTS', filepath ]
    } else {
      return [ 'DO_NOTHING', filepath ]
    }
  }
  
  const actions = await Promise.all(config.defaults.map(toAction))

  const performDefaultFileAction = ([ action, relative ] : Action) : Promise<any> =>
    action === 'CREATE_IN_DEFAULTS' ? createDefaultFile(relative)
    : action === 'DELETE_FROM_DEFAULTS' ? deleteFromDefaults(relative)
    : Promise.resolve()

  const createDefaultFile = async (relative : string[]) =>
    File.copyFile(
      path.join(config.folders.defaults.src, ...relative),
      path.join(config.folders.defaults.dest, ...relative)
    )

  const deleteFromDefaults = async (relative : string[]) =>
    File.remove(path.join(config.folders.defaults.dest, ...relative))

  return Promise.all(actions.map(performDefaultFileAction))
}

const scanForStaticPages = async (entries: PageEntry[]) : Promise<string[][]> => {
  const contents = await Promise.all(entries.map(e => File.read(e.filepath)))
  return contents
    .map((content, i) => isStaticPage(content) ? i : undefined)
    .filter(a => typeof a === 'number')
    .map((i : any) => entries[i].segments)
}

const createGeneratedFiles = async () => {
  const entries = await getAllPageEntries()
  const filepaths = entries.map(e => e.segments)

  const staticPages = await scanForStaticPages(entries)
  const isStatic = (path : string[]) => staticPages.map(p => p.join('.')).includes(path.join('.'))

  const paramFiles = filepaths.map(filepath => ({
    filepath: [ 'Gen', 'Params', ...filepath ],
    contents: ParamsTemplate(filepath, { isStatic })
  }))

  const filesToCreate = [
    ...paramFiles,
    { filepath: [ 'Gen', 'Route' ], contents: RouteTemplate(filepaths, { isStatic }) },
    { filepath: [ 'Gen', 'Pages' ], contents: PagesTemplate(filepaths, { isStatic }) },
    { filepath: [ 'Gen', 'Model' ], contents: ModelTemplate(filepaths, { isStatic }) },
    { filepath: [ 'Gen', 'Msg' ], contents: MsgTemplate(filepaths, { isStatic }) }
  ]

  return Promise.all(filesToCreate.map(({ filepath, contents }) =>
    File.create(path.join(config.folders.generated, ...filepath) + '.elm', contents))
  )
}

type PageEntry = {
  filepath: string;
  segments: string[];
}

const getAllPageEntries = async () : Promise<PageEntry[]> => {
  const scanPageFilesIn = async (folder : string) => {
    const items = await File.scan(folder)
    return items.map(s =>({
      filepath: s,
      segments: s.substring(folder.length + 1, s.length - '.elm'.length).split(path.sep)
    }))
  }
  
  return Promise.all([
    scanPageFilesIn(config.folders.pages.src),
    scanPageFilesIn(config.folders.pages.defaults)
  ]).then(([ left, right ]) => left.concat(right))
}

type Environment = 'production' | 'development'

const output = path.join(config.folders.dist, 'elm.js')

const compileMainElm = (env : Environment) => async () => {
  const start = Date.now()

  const elmMake = async () => {
    const flags = env === 'development' ? '--debug' : '--optimize'

    const isSrcMainElmDefined = await File.exists(path.join(config.folders.src, 'Main.elm'))  
    const input = isSrcMainElmDefined
      ? path.join(config.folders.src, 'Main.elm')
      : path.join(config.folders.defaults.dest, 'Main.elm')

    
    if (await File.exists(config.folders.dist) === false) {
      await File.mkdir(config.folders.dist)
    }

    return Process.run(`${config.binaries.elm} make ${input} --output=${output} --report=json ${flags}`)  
      .catch(colorElmError)
  }

  const red = colors.RED
  const green = colors.green

  const colorElmError = (err : string) => {
    let errors = []

    try {
      errors = JSON.parse(err).errors as Error[] || []
    } catch (e) {
      return Promise.reject([
        `${red}Something went wrong with elm-spa.${reset}`,
        `Please report this entire error to ${green}https://github.com/ryannhg/elm-spa/issues${reset}`,
        `-----`,
        err,
        `-----`
      ].join('\n\n'))
    }

    const strIf = (str : string) => (cond : boolean) : string => cond ? str : ''
    const boldIf = strIf(bold)
    const underlineIf = strIf(underline)

    type Error = {
      path : string
      problems: Problem[]
    }

    type Problem = {
      title : string
      message : (Message | string)[]
    }

    type Message = {
      bold : boolean
      underline : boolean
      color : keyof typeof colors
      string : string
    }

    const repeat = (str : string, num : number, min = 3) => [...Array(num < 0 ? min : num)].map(_ => str).join('')

    const errorToString = (error : Error) : string => {
      const problemToString = (problem : Problem) : string => {
        const path = error.path.substr(process.cwd().length + 1)
        return [
          `${colors.cyan}-- ${problem.title} ${repeat('-', 63 - problem.title.length - path.length)} ${path}${reset}`,
          problem.message.map(messageToString).join('')
        ].join('\n\n')
      }
      
      const messageToString = (line : Message | string) =>
        typeof line === 'string'
          ? line
          : [ boldIf(line.bold), underlineIf(line.underline), colors[line.color] || '', line.string, reset ].join('')

      return error.problems.map(problemToString).join('\n\n')
    }

    return errors.length
      ? Promise.reject(errors.map(errorToString).join('\n\n\n'))
      : err
  }

  const success = () => `${check} Build successful! ${dim}(${Date.now() - start}ms)${reset}`

  const minify = () =>
    Process.run(`${config.binaries.terser} ${output} --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | ${config.binaries.terser} --mangle --output=${output}`)

  return (env === 'development')
    ? elmMake()
        .then(_ => success()).catch(error => error)
    : elmMake().then(minify)
        .then(_ => [ success() + '\n' ])
  }
  
export default {
  run: build('production')
}
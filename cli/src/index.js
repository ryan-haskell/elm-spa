#!/usr/bin/env node
const package = require('../package.json')
const path = require('path')
const cwd = process.cwd()
const { File, Elm, bold } = require('./utils.js')

const main = ([ command, ...args ] = []) =>
  commands[command]
    ? commands[command](args)
    : commands.help(args)

// elm-spa init
const init = (args) => {
  const parseInitArgs = (args) => {
    const flagPrefix = '--'
    const isFlag = arg => arg.indexOf(flagPrefix) == 0

    const flags =
      args.filter(isFlag)
        .reduce((obj, arg) => {
          const [ key, value ] = arg.split('=')
          obj[key.substring(flagPrefix.length)] = value
          return obj
        }, {})

    const [ relative = '.' ] = args.filter(arg => !isFlag(arg))

    return { ui: flags.ui || 'Element', relative }
  }

  const { ui, relative } = parseInitArgs(args)

  return Promise.resolve(
    (ui === 'Element')
      ? File.cp(path.join(__dirname, '..', 'initial-projects', 'elm-ui'), path.join(cwd, relative))
      : File.cp(path.join(__dirname, '..', 'initial-projects', 'html'), path.join(cwd, relative))
  )
    .then(_ => console.info(`
${bold('elm-spa')} created a new project in:

  ${path.join(cwd, relative)}

  run these commands to get started:
  ${bold('cd ' + path.join(cwd, relative))}
  ${bold('npm start')}
`))
    .catch(console.error)
}

// elm-spa add
const add = args =>
  Elm.friendlyAddMessages(args)
    .then(_ => {
      const [ pageType, moduleName, relative = '.' ] = args
      const dir = path.join(cwd, relative)

      return Elm.checkForElmSpaJson(dir)
        .then(config =>
          File.paths(path.join(dir, 'src', 'Layouts'))
            .then(layoutPaths => Elm.run('add', { relative })({
              pageType,
              moduleName,
              layoutPaths,
              ui: config.ui
            }))
            .then(Elm.formatOutput)
        )
        .then(str => `\n${str}\n`)
    })
    .then(console.info)
    .catch(console.error)

// elm-spa build
const build = ([ relative = '.' ]) => {
  const dir = path.join(cwd, relative)

  return Elm.checkForElmSpaJson(dir)
    .then(json =>
      File.paths(path.join(dir, 'src', 'Pages'))
        .then(Elm.run('build', { relative }, json['elm-spa']))
        .then(Elm.formatOutput)
    )
    .then(str => `\n${str}\n`)
    .then(console.info)
    .catch(console.error)
  }

const version =
  `${bold('elm-spa')} ${package.version}`

// elm-spa help
const help = () => console.info(`
${version}

usage: ${bold('elm-spa')} <command> [...]

commands:

  ${bold('init')} [options] <path>     create a new project at <path>

  options:
     ${bold('--ui=')}<module>          the ui module your \`view\` uses
                            (default: Element)

                            examples:
                            ${bold('elm-spa init your-project')}
                            ${bold('elm-spa init --ui=Html your-project')}

  ${bold('build')} <path>              generate pages and routes

                            examples:
                            ${bold('elm-spa build .')}

  ${bold('add')} static <module>       create a new static page
      sandbox <module>      create a new sandbox page
      element <module>      create a new element page
      component <module>    create a new component page

                            examples:
                            ${bold('elm-spa add static AboutUs')}
                            ${bold('elm-spa add element Settings.Index')}

  ${bold('help')}                      print this help screen

                            examples:
                            ${bold('elm-spa help')}
                            ${bold('elm-spa wat')}
`)

const commands = {
  init,
  add,
  build,
  help,
  '-v': _ => console.info(version)
}

main(process.argv.slice(2))
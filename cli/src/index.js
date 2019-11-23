#!/usr/bin/env node
const path = require('path')
const cwd = process.cwd()
const { File, Elm, bold } = require('./utils.js')

const main = ([ command, ...args ] = []) =>
  commands[command]
    ? commands[command](args)
    : commands.help(args)

// elm-spa add
const add = args =>
  Elm.friendlyAddMessages(args)
    .then((args = []) => {
      const [ pageType, moduleName, relative = '.' ] = args
      const dir = path.join(cwd, relative)

      return Elm.checkForElmJson(dir)
        .then(({ 'elm-spa': config }) =>
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

  return Elm.checkForElmJson(dir)
    .then(json =>
      File.paths(path.join(dir, 'src', 'Pages'))
        .then(Elm.run('build', { relative }, json['elm-spa']))
        .then(Elm.formatOutput)
    )
    .then(str => `\n${str}\n`)
    .then(console.info)
    .catch(console.error)
  }

// elm-spa help
const help = () => console.info(`
usage: ${bold('elm-spa')} <command> [...]

commands:

  ${bold('init')} [options] <path>      create a new project at <path>

  options:
     ${bold('--ui=')}<module>           the module your \`view\` uses (default: Html)

                             examples:
                             ${bold('elm-spa init your-project')}
                             ${bold('elm-spa init --ui=Element your-project')}

                            
  ${bold('build')} <path>               generate pages and routes

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
                            ${bold('elm-spa huh?')}
`)

const commands = {
  add,
  build,
  help
}

main(process.argv.slice(2))
#!/usr/bin/env node
const path = require('path')
const cwd = process.cwd()
const { File, Elm, bold } = require('./utils.js')

const start = ([ command, ...args ] = []) =>
  commands[command]
    ? commands[command](args)
    : commands.help(args)

// elm-spa build
const build = ([ relative = '.' ]) =>
  File.paths(path.join(cwd, relative, 'src', 'Pages'))
    .then(Elm.run('build', { relative }))
    .then(console.info)
    .catch(console.error)

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
  build,
  help
}

start(process.argv.slice(2))
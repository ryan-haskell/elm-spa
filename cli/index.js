#!/usr/bin/env node

const utils = {
  all: fn => items => Promise.all(items.map(fn)),
  bold: str => '\033[1m' + str + '\033[0m'
}

const main = ([ command, ...args = [] ] = []) => {
  const commands = { help, init, build }
  return (commands[command] || commands.help)(args)
}

const help = _ => console.info(
`usage: elm-spa <command> [options]

commands:
  help                      prints this help screen
  build [options] <path>    generates pages and routes
  init [options] <path>     scaffolds a new project at <path>

options:
  --ui=<Html|Element>       what your \`view\` returns (default: Html)
`)

const init = _ =>
  console.info(`Hey there, this still needs implementation 😬`)

const build = (args = []) => {
  const fs = require('fs')
  const path = require('path')
  const cwd = process.cwd()
  const { Elm } = require('./dist/elm.compiled.js')

  const optionArgs = args.filter(a => a.startsWith('--'))
  const nonOptionArgs = args.filter(a => a.startsWith('--') === false)
  const grabOption = (prefix) => optionArgs.filter(option => option.startsWith(prefix)).split(prefix)[1]

  const relative = nonOptionArgs.slice(-1)[0] || '.'
  const options = {
    ui: grabOption('--ui=')
  }

  const exploreFolder = (filepath) => {
    const tag = (item) =>
      item.endsWith('.elm')
        ? Promise.resolve({ type: 'file', name: item })
        : exploreFolder(path.join(filepath, item))
            .then(children => ({ type: 'folder', name: item, children }))

    return new Promise(
      (resolve, reject) => fs.readdir(filepath, (err, files) => err ? reject(err) : resolve(files))
    ).then(utils.all(tag))
  }

  const passToElm = (folders) => new Promise((resolve) => {
    const app = Elm.Main.init({ flags: { folders, options } })
    app.ports.toJs.subscribe(stuff => resolve(stuff))
  })

  const writeToFolder = (srcFolder) => ({ filepathSegments, contents }) =>
    new Promise((resolve, reject) => {
      const folder = path.join(srcFolder, ...filepathSegments.slice(0, -1))
      if (!fs.existsSync(folder)) {
        fs.mkdirSync(folder)
      }
      const filepath = path.join(srcFolder, ...filepathSegments)
      fs.writeFile(filepath, contents, { encoding: 'utf8' }, (err, _) => err ? reject(err) : resolve(filepath))
    })

  exploreFolder(path.join(cwd, relative, 'src', 'Pages'))
    .then(passToElm)
    .then(utils.all(writeToFolder(path.join(cwd, relative, 'src'))))
    .then(files => {
      const lines = files.map(file => `${utils.bold(' 🌳 ')} ${file}`).join('\n')
      console.info(`${utils.bold('elm-spa generated:')}\n${lines}\n`)
    })
    .catch(console.error)
}

// runs the things
main([...process.argv].slice(2))

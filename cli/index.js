#!/usr/bin/env node
const fs = require('fs')
const path = require('path')
const cwd = process.cwd()
const { Elm } = require('./dist/elm.compiled.js')

const main = ([ command, ...args ] = []) => {
  const commands = {
    help: _ => console.log('help'),
    run: generate,
    generate: generate
  }

  return (commands[command] || commands.help)(args || [])
}

const generate = ([ relative = '.' ] = []) =>
  dir(path.join(cwd, relative, 'src', 'Pages'))
    .then(passToElm)
    .then(utils.all(writeToFolder(path.join(cwd, relative, 'src'))))
    .then(files => {
      const lines = files.map(file => `${utils.bold(' 🌳 ')} ${file}`).join('\n')
      console.info(`${utils.bold('elm-spa generated:')}\n${lines}\n`)
    })
    .catch(console.error)

const dir = (filepath) => {
  const tag = (item) =>
    item.endsWith('.elm')
      ? Promise.resolve({ type: 'file', name: item })
      : dir(path.join(filepath, item)).then(children =>
          ({ type: 'folder', name: item, children })
        )

  return new Promise((resolve, reject)=>
    fs.readdir(filepath, (err, files) => err ? reject(err) : resolve(files))
  )
    .then(utils.all(tag))
}

const passToElm = (json) => new Promise((resolve) => {
  const app = Elm.Main.init({ flags: json })
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

const utils = {
  all: fn => items => Promise.all(items.map(fn)),
  bold: str => '\033[1m' + str + '\033[0m'
}


main([...process.argv].slice(2))
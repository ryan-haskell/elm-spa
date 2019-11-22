const path = require('path')
const fs = require('fs')
const cwd = process.cwd()

const File = (_ => {

  const mkdir = (filepath) =>
    new Promise((resolve, reject) =>
      fs.mkdir(filepath, { recursive: true }, (err) => err ? reject(err) : resolve(filepath))
    )

  const create = (filepath, contents) => {
    // this will surely break windows, im tired and sorry i wrote this line.
    const folderOf = (path) => path.split('/').slice(0, -1).join('/')

    const write = (filepath, contents) =>
      new Promise((resolve, reject) =>
        fs.writeFile(filepath, contents, { encoding: 'utf8' }, (err) =>
          err ? reject(err) : resolve(filepath)
        )
      )

    return fs.existsSync(folderOf(filepath))
      ? write(filepath, contents)
      : mkdir(folderOf(filepath)).then(_ => write(filepath, contents))
  }

  const paths = (filepath) => {
    const ls = (filepath) =>
      new Promise((resolve, reject) =>
        fs.readdir(filepath, (err, files) =>
          err ? reject(err) : resolve(files))
      )

    const reduce = (fn, init) => (items) =>
      items.reduce(fn, init)

    const concat = (a, b) =>
      a.concat(b)

    const all = (fn) => (items) =>
      Promise.all(items.map(fn))

    const isFile = (name) =>
      name.indexOf('.') > -1

    const toPath = (filepath) => (name) =>
      isFile(name)
        ? Promise.resolve([[ name.split('.')[0] ]])
        : paths(path.join(filepath, name))
            .then(files => files.map(file => [ name ].concat(file)))

    return ls(filepath)
      .then(all(toPath(filepath)))
      .then(reduce(concat, []))
  }

  return {
    paths,
    mkdir,
    create
  }
})()

const Elm = (_ => {
  const { Elm } = require('../dist/elm.compiled.js')

  const handlers = {
    error: (_, message) =>
      Promise.reject(message),
    createFiles: ({ relative }, files) =>
      Promise.all(
        files
          .map(item => ({
            ...item,
            filepath: path.join(cwd, relative, 'elm-stuff', '.elm-spa', 'Generated', ...item.filepath) + '.elm'
          }))
          .map(item => File.create(item.filepath, item.contents))
      )
  }

  const run = (command, args) => (data) =>
    new Promise((resolve, reject) => {
      const app = Elm.Main.init({ flags: { command, data } })

      app.ports.outgoing.subscribe(({ message, data }) =>
        handlers[message]
          ? Promise.resolve(handlers[message](args, data)).then(resolve).catch(reject)
          : reject(`Didn't recognize message "${message}"– Yell at @ryannhg on the internet!\n`)
      )
    })

  const checkForElmJson = (paths) =>
    new Promise((resolve, reject) =>
      fs.readFile(path.join(paths, 'elm.json'), (_, contents) =>
        contents
          ? Promise.resolve(contents.toString())
              .then(JSON.parse)
              .then(resolve)
              .catch(_ => `Couldn't understand the ${bold('elm.json')} file at:\n${paths}`)
          : reject(`Couldn't find an ${bold('elm.json')} file at:\n${paths}`)
      )
    )

  const alphabetically = (a, b) =>
    (a < b) ? -1 : (a > b) ? 1 : 0

  const formatOutput = files => [
    bold('elm-spa') + ` created ${bold(files.length)} file${files === 1 ? '' : 's'}:`,
    files.sort(alphabetically).map(file => '  ' + file).join('\n'),
  ].join('\n\n')
 
  return { run, checkForElmJson, formatOutput }
})()

const bold = str => '\033[1m' + str + '\033[0m'

module.exports = {
  Elm,
  File,
  bold
}
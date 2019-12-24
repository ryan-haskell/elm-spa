const path = require('path')
const fs = require('fs')
const cwd = process.cwd()

const File = (_ => {
  const mkdir = (filepath) =>
    new Promise((resolve, reject) =>
      fs.mkdir(filepath, { recursive: true },
        (err) => err ? reject(err) : resolve(filepath)
      )
    )

  const read = (filepath) =>
    new Promise((resolve, reject) =>
      fs.readFile(filepath, (err, data) =>
        err ? reject(err) : resolve(data.toString('utf8')) 
      )
    )

  const cp = (src, dest) => {
    const exists = fs.existsSync(src)
    const stats = exists && fs.statSync(src)
    if (stats && stats.isDirectory()) {
      fs.mkdirSync(dest)
      fs.readdirSync(src).forEach(child =>
        cp(path.join(src, child), path.join(dest, child))
      )
    } else {
      fs.copyFileSync(src, dest)
    }
  }

  const deleteFolderRecursive = (filepath) => {
    if (fs.existsSync(filepath)) {
      fs.readdirSync(filepath).forEach(file => {
        const current = path.join(filepath, file)
        if (fs.lstatSync(current).isDirectory()) {
          deleteFolderRecursive(current)
        } else {
          fs.unlinkSync(current)
        }
      })
      fs.rmdirSync(filepath)
    }
  }

  const rmdir = (folder) => new Promise((resolve, reject) => {
    try {
      deleteFolderRecursive(folder)
      resolve()
    } catch (err) {
      reject(err)
    }
  })

  const create = (filepath, contents) => {
    const folderOf = (path_) =>
      path_.split(path.sep).slice(0, -1).join(path.sep)

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
        ? Promise.resolve(
            name.split('.')[1] == 'elm'
              ? [[ name.split('.')[0] ]]
              : []
          )
        : paths(path.join(filepath, name))
            .then(files => files.map(file => [ name ].concat(file)))

    return ls(filepath)
      .then(all(toPath(filepath)))
      .then(reduce(concat, []))
  }

  return {
    read,
    paths,
    mkdir,
    rmdir,
    cp,
    create
  }
})()

const Elm = (_ => {
  const { Elm } = require('../dist/elm.compiled.js')

  const handlers = {
    error: (_, message) =>
      Promise.reject(message),
    createFiles: ({ relative }, files) =>
      File.rmdir(path.join(cwd, relative, 'elm-stuff', '.elm-spa', 'Generated'))
        .then(_ =>
          Promise.all(
            files
              .map(item => ({
                ...item,
                filepath: path.join(cwd, relative, ...item.filepath) + '.elm'
              }))
              .map(item => File.create(item.filepath, item.contents))
          )
        )
  }

  const run = (command, args) => (data) =>
    new Promise((resolve, reject) => {
      const app = Elm.Main.init({ flags: { command, data } })

      app.ports.outgoing.subscribe(({ message, data }) =>
        handlers[message]
          ? Promise.resolve(handlers[message](args, data))
              .then(resolve)
              .catch(reject)
          : reject(`Didn't recognize message "${message}"– yell at @ryannhg on the internet!\n`)
      )
    })

  const checkForElmSpaJson = (paths) =>
    new Promise((resolve, reject) =>
      fs.readFile(path.join(paths, 'elm-spa.json'), (_, contents) =>
        contents
          ? Promise.resolve(contents.toString())
              .then(JSON.parse)
              .then(resolve)
              .catch(_ => `Couldn't understand the ${bold('elm-spa.json')} file at:\n${paths}`)
          : reject(`Couldn't find an ${bold('elm-spa.json')} file at:\n${paths}`)
      )
    )

  const alphabetically = (a, b) =>
    (a < b) ? -1 : (a > b) ? 1 : 0

  const formatOutput = files => [
    bold('elm-spa') + ` created ${bold(files.length)} file${files.length === 1 ? '' : 's'}:`,
    files.sort(alphabetically).map(file => '  ' + file).join('\n'),
  ].join('\n\n')

  const friendlyAddMessages = (args = []) => {
    const [ page, moduleName, relative = '.' ] = args
  
    const expectedFiles = [
      path.join(cwd, relative, 'elm-spa.json'),
      path.join(cwd, relative, 'src', 'Layouts')
    ]
  
    if (expectedFiles.some(file => !fs.existsSync(file))) {
      return Promise.reject(`\n  I don't see an elm-spa project here...\n\n  Please run this command in the directory with your ${bold('elm-spa.json')}\n`)
    }
  
    const isValidPage = {
      'static': true,
      'sandbox': true,
      'element': true,
      'component': true
    }
  
    const isValidModuleName = (name = '') => {
      const isAlphaOnly = word => word.match(/[A-Z|a-z]+/)[0] === word
      const isCapitalized = word => word[0].toUpperCase() === word[0]
      return name &&
        name.length &&
        name.split('.').every(word => isAlphaOnly(word) && isCapitalized(word))
    }
  
    const messages = {
      invalidPage: ({ page, name }) => `
  ${bold(page)} is not a valid page.

  Try one of these?
  ${bold(Object.keys(isValidPage).map(page => `elm-spa add ${page} ${name}`).join('\n  '))}
      `,
      invalidModuleName: ({ page, name }) => `
  ${bold(name)} doesn't look like an Elm module.

  Here are some examples of what I'm expecting:
  ${bold(`elm-spa add ${page} Example`)}
  ${bold(`elm-spa add ${page} Settings.User`)}
      `
    }
  
    if (isValidPage[page] !== true) {
      return Promise.reject(messages.invalidPage({
        page,
        name: isValidModuleName(moduleName) ? moduleName : 'Example'
      }))
    } else if (isValidModuleName(moduleName) === false) {
      return Promise.reject(messages.invalidModuleName({ page, name: moduleName }))
    } else {
      return Promise.resolve(args)
    }
  }
 
  return { run, checkForElmSpaJson, formatOutput, friendlyAddMessages }
})()

const bold = str => '\033[1m' + str + '\033[0m'

module.exports = {
  Elm,
  File,
  bold
}

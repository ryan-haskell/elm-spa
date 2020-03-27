#!/usr/bin/env node
const path = require('path')
const fs = require('fs')
const { Elm } = require('./dist/elm.worker.js')
const package = require('./package.json')

// File stuff
const folders = {
  src: (dir) => path.join(process.cwd(), dir, 'src'),
  pages: (dir) => path.join(process.cwd(), dir, 'src', 'Pages'),
  generated: (dir) => path.join(process.cwd(), dir, 'src', 'Generated')
}

const rejectIfMissing = (dir) => new Promise((resolve, reject) =>
  fs.existsSync(dir) ? resolve(true) : reject(false)
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

const listFiles = (dir) =>
  fs.readdirSync(dir)
    .reduce((files, file) =>
      fs.statSync(path.join(dir, file)).isDirectory() ?
        files.concat(listFiles(path.join(dir, file))) :
        files.concat(path.join(dir, file)),
      [])

const ensureDirectory = (dir) =>
  fs.mkdirSync(dir, { recursive: true })

const saveToFolder = (prefix) => ({ filepath, content }) =>
  fs.writeFileSync(path.join(prefix, filepath), content, { encoding: 'utf8' })

// Formatting output
const bold = (str) => '\033[1m' + str + '\033[0m'
const toFilepath = name => path.join(folders.pages('.'), `${name.split('.').join('/')}.elm`)

// Flags + Validation
const flags = { command: '', name: '', pageType: '', filepaths: [] }

const isValidPageType = type =>
  [ 'static', 'sandbox', 'element', 'component' ].some(x => x === type)

const isValidModuleName = (name = '') => {
  const isAlphaOnly = word => word.match(/[A-Z|a-z]+/)[0] === word
  const isCapitalized = word => word[0].toUpperCase() === word[0]
  return name &&
    name.length &&
    name.split('.').every(word => isAlphaOnly(word) && isCapitalized(word))
}

// Help commands
const help = {
  general: `
  ${bold('elm-spa')} – version ${package.version}
  
    ${bold('elm-spa init')} – create a new project
    ${bold('elm-spa add')} – add a new page
    ${bold('elm-spa build')} – generate files
    
    ${bold('elm-spa <command> help')} – get detailed help for a command
    ${bold('elm-spa -v')} – print version number
`,

  init: `
  ${bold('elm-spa init')} <directory>

    Create a new elm-spa app in the <directory>
    folder specified.

    ${bold('examples:')}
    elm-spa init .
    elm-spa init my-app
`,

  add: `
  ${bold('elm-spa add')} <static|sandbox|element|component> <name>

    Create a new page of type <static|sandbox|element|component>
    with the module name <name>.

    ${bold('examples:')}
    elm-spa add static Top
    elm-spa add sandbox Posts.Top
    elm-spa add element Posts.Dynamic
    elm-spa add component SignIn
`,

  build: `
  ${bold('elm-spa build')} [dir]

    Generate "Generated.Route" and "Generated.Pages" for
    this project, based on the files in src/Pages/*

    Optionally, you can specify a different directory.

    ${bold('examples:')}
    elm-spa build
    elm-spa build ../some/other-folder
    elm-spa build ./help
`

}

const toUnixFilepath = (filepath) =>
  filepath.split(path.sep).join('/')

// Available commands
const commands = {

  'init': ([ folder ]) =>
    folder && folder !== 'help'
      ? Promise.resolve()
          .then(_ => {
            const dest = path.join(process.cwd(), folder)
            cp(path.join(__dirname, 'projects', 'new'), dest)
            try { fs.renameSync(path.join(dest, '.npmignore'), path.join(dest, '.gitignore')) } catch (_) {}
          })
          .then(_ => `\ncreated a new project in ${path.join(process.cwd(), folder)}\n`)
          .catch(_ => `\nUnable to initialize a project at ${path.join(process.cwd(), folder)}\n`)
      : Promise.resolve(help.init),

  'add': ([ type, name ]) =>
    (type && name) && type !== 'help' && isValidPageType(type) && isValidModuleName(name)
      ? rejectIfMissing(folders.pages('.'))
          .then(_ => new Promise(
            Elm.Main.init({ flags: { ...flags, command: 'add', name: name, pageType: type } }).ports.addPort.subscribe)
          )
          .then(file => {
            const containingFolder = path.join(folders.pages('.'), file.filepath.split('/').slice(0, -1).join('/'))
            ensureDirectory(containingFolder)
            saveToFolder((folders.pages('.')))(file)
          })
          .then(_ => `\nadded a new ${bold(type)} page at:\n${toFilepath(name)}\n`)
          .catch(_ => `\nplease run ${bold('elm-spa add')} in the folder with ${bold('elm.json')}\n`)
      : Promise.resolve(help.add),

  'build': ([ dir  = '.' ] = []) =>
    dir !== 'help'
      ? Promise.resolve(folders.pages(dir))
          .then(listFiles)
          .then(names => names.filter(name => name.endsWith('.elm')))
          .then(names => names.map(name => name.substring(folders.pages(dir).length)))
          .then(filepaths => new Promise(
            Elm.Main.init({ flags: { ...flags, command: 'build', filepaths: filepaths.map(toUnixFilepath) } }).ports.buildPort.subscribe
          ))
          .then(files => {
            ensureDirectory(folders.generated(dir))
            files.forEach(saveToFolder(folders.src(dir)))
            return files
          })
          .then(files => `\nelm-spa generated two files:\n${files.map(({ filepath }) => '  - ' + path.join(folders.src(dir), filepath)).join('\n')}\n`)
          .catch(_ => `\nplease run ${bold('elm-spa build')} in the folder with ${bold('elm.json')}\n`)
      : Promise.resolve(help.build),

  '-v': _ => Promise.resolve(package.version),

  'help': _ => Promise.resolve(help.general)
    
}

const main = ([ command, ...args ] = []) =>
  (commands[command] || commands['help'])(args)
    // .then(_ => args.data.slice)
    .then(console.info)
    .catch(reason => {
      console.info(`\n${bold('Congratulations!')} - you've found a bug!
    
  If you'd like, open an issue here with the following output:
  https://github.com/ryannhg/elm-spa/issues/new?labels=cli


${bold(`### terminal output`)}
`)
console.log('```')
      console.error(reason)
      console.log('```\n')
    })

main([...process.argv.slice(2)])

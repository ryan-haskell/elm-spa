#!/usr/bin/env node
const prompts = require('prompts')
const path = require('path')
const fs = require('fs')
const { Elm } = require('./dist/elm.worker.js')
const package = require('./package.json')

// File stuff
const folders = {
  src: (dir) => path.join(process.cwd(), dir, 'src'),
  pages: (dir) => path.join(process.cwd(), dir, 'src', 'Pages'),
  generated: (dir) => path.join(process.cwd(), dir, 'src', 'Spa', 'Generated')
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
  fs.existsSync(dir) || fs.mkdirSync(dir, { recursive: true })

const saveToFolder = (prefix) => ({ filepath, content }) =>
  fs.writeFileSync(path.join(prefix, filepath), content, { encoding: 'utf8' })

// Formatting output
const bold = (str) => '\033[1m' + str + '\033[0m'
const green = (str) => '\033[32m' + str + '\033[0m'
const toFilepath = name => path.join(folders.pages('.'), `${name.split('.').join('/')}.elm`)

// Flags + Validation
const flags = { command: '', name: '', pageType: '', filepaths: [] }

const isValidPageType = type =>
  [ 'static', 'sandbox', 'element', 'application' ].some(x => x === type)

const isValidModuleName = (name = '') => {
  const isAlphaOrUnderscoreOnly = word => word.match(/[A-Z|a-z|_]+/)[0] === word
  const isCapitalized = word => word[0].toUpperCase() === word[0]
  return name &&
    name.length &&
    name.split('.').every(word => isAlphaOrUnderscoreOnly(word) && isCapitalized(word))
}

// Help commands
const help = `
  ${bold('elm-spa')} – version ${package.version}
  
    ${bold('elm-spa init')} – create a new project
    ${bold('elm-spa add')} – add a new page
    ${bold('elm-spa build')} – generate routes and pages automatically
    
    ${bold('elm-spa version')} – print the version number
`

const toUnixFilepath = (filepath) =>
  filepath.split(path.sep).join('/')

// Fancy interactive prompts
const interactivePrompts = {
  'init': _ => prompts([
    {
      type: 'select',
      name: 'ui',
      message: 'UI package?',
      choices: [
        { title: 'elm-ui', value: 'elm-ui', description: '"What if you never had to write CSS again?"' },
        { title: 'html', value: 'html', description: '"Use HTML in Elm!"' },
        { title: 'elm-css', value: 'elm-css', description: '"Typed CSS in Elm."' }
      ],
      initial: 0
    },
    {
      type: 'text',
      name: 'name',
      message: `What's the folder name?`,
      initial: 'my-elm-spa',
      validate: (input) =>
        /[a-z\-]+/.test(input) || 'Lowercase letters and dashes only.'
    }
  ], { onCancel: _ => process.exit(0) }),

  'add': _ => prompts([
    {
      type: 'select',
      name: 'type',
      message: 'What kind of page?',
      choices: [
        { title: 'static', value: 'static', description: 'A simple, static page' },
        { title: 'sandbox', value: 'sandbox', description: 'Needs to manage local state' },
        { title: 'element', value: 'element', description: 'Needs to send Cmd msg or receive Sub msg' },
        { title: 'application', value: 'application', description: 'Needs read-write access to Shared.Model' },
      ],
      initial: 0
    },
    {
      type: 'text',
      name: 'name',
      message: `What's the module name?`,
      hint: 'Example: "Posts.Id_Int"',
      validate: (input) =>
        isValidModuleName(input) || 'Must be a valid Elm module name.'
    }
  ], { onCancel: _ => process.exit(0) })
}

// Available commands
const commands = {

  'init': ([ template, folder ]) =>
    template && folder && [ 'html', 'elm-css', 'elm-ui' ].includes(template)
      ? Promise.resolve()
          .then(_ => {
            const dest = path.join(process.cwd(), folder)
            cp(path.join(__dirname, 'templates', template), dest)
            try { fs.renameSync(path.join(dest, '.npmignore'), path.join(dest, '.gitignore')) } catch (_) {}
          })
          .then(_ => `\n${green('✔')} Created a new project in ${path.join(process.cwd(), folder)}\n`)
          .catch(_ => `\nUnable to initialize a project at ${path.join(process.cwd(), folder)}\n`)
      : interactivePrompts.init()
          .then(({ ui, name }) => commands.init([ ui, name ])),

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
          .then(_ => `\n${green('✔')} Added a new ${bold(type)} page at:\n${toFilepath(name)}\n`)
          .catch(_ => `\nPlease run ${bold('elm-spa add')} in the folder with ${bold('elm.json')}\n`)
      : interactivePrompts.add()
          .then(({ type, name }) => commands.add([ type, name ])),

  'build': (_, dir = '.') =>
    Promise.resolve(folders.pages(dir))
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
      .then(_ => `\n${green('✔')} elm-spa build complete!\n`)
      .catch(_ => `\nPlease run ${bold('elm-spa build')} in the folder with ${bold('elm.json')}\n`),

  '-v': _ => Promise.resolve(package.version),

  'version': _ => Promise.resolve(package.version),

  'help': _ => Promise.resolve(help)
    
}

const main = ([ command, ...args ] = []) =>
  (commands[command] || commands['help'])(args)
    .then(console.info)
    .catch(reason => {
      console.info(`\n${bold('Congratulations!')} - you've found a bug!
    
  If you'd like, open an issue here with the following output:
  https://github.com/ryannhg/elm-spa/issues/new?labels=cli-crash


${bold(`### terminal output`)}
`)
console.log('```')
      console.error(reason)
      console.log('```\n')
    })

main([...process.argv.slice(2)])

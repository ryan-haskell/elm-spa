#!/usr/bin/env node
const fs = require('fs')
const path = require('path')
const cwd = process.cwd()

const utils = {
  all: fn => items => Promise.all(items.map(fn)),
  bold: str => '\033[1m' + str + '\033[0m',
  cp (src, dest) {
    const exists = fs.existsSync(src)
    const stats = exists && fs.statSync(src)
    if (stats.isDirectory()) {
      fs.mkdirSync(dest)
      fs.readdirSync(src).forEach(child =>
        this.cp(path.join(src, child), path.join(dest, child))
      )
    } else {
      fs.copyFileSync(src, dest)
    }
  },
  exploreFolder (filepath) {
    const tag = (item) =>
      item.endsWith('.elm')
        ? Promise.resolve({ type: 'file', name: item })
        : this.exploreFolder(path.join(filepath, item))
            .then(children => ({ type: 'folder', name: item, children }))

    return new Promise(
      (resolve, reject) => fs.readdir(filepath, (err, files) => err ? reject(err) : resolve(files))
    ).then(utils.all(tag))
  },
  sendToElm : (relative) => (flags) => {
    const writeToFolder = (srcFolder) => ({ filepathSegments, contents }) =>
      new Promise((resolve, reject) => {
        const folder = path.join(srcFolder, ...filepathSegments.slice(0, -1))
        if (!fs.existsSync(folder)) {
          fs.mkdirSync(folder, { recursive: true })
        }
        const filepath = path.join(srcFolder, ...filepathSegments)
        fs.writeFile(filepath, contents, { encoding: 'utf8' }, (err, _) => err ? reject(err) : resolve(filepath))
      })

    return new Promise((resolve) => {
      const { Elm } = require('./dist/elm.compiled.js')
      const app = Elm.Main.init({ flags })
      app.ports.toJs.subscribe(stuff => resolve(stuff))
    })
      .then(utils.all(writeToFolder(path.join(cwd, relative, 'src'))))
      .then(files => {
        const lines = files.map(file => `${utils.bold(' 🌳 ')} ${file}`).join('\n')
        console.info(`${utils.bold('elm-spa generated:')}\n${lines}\n`)
      })
      .catch(console.error)
  }
}

const main = ([ command, ...args ] = []) => {
  const commands = { help, init, build, add }
  return (commands[command] || commands.help)(args || [])
}

const help = _ =>
  console.info(`
usage: ${utils.bold('elm-spa')} <command> [...]

commands:

🌳  ${utils.bold('init')} <path>               create a new project at <path>

                             examples:
                             ${utils.bold('elm-spa init your-project')}


🌳  ${utils.bold('build')} [options] <path>    generate pages and routes

   options:
     ${utils.bold('--ui=')}<module>           the module your \`view\` uses (default: Html)

                             examples:
                             ${utils.bold('elm-spa build your-project')}
                             ${utils.bold('elm-spa build --ui=Element your-project')}


🌳  ${utils.bold('add')} static <module>       create a new static page
       sandbox <module>      create a new sandbox page
       element <module>      create a new element page
       component <module>    create a new component page

                             examples:
                             ${utils.bold('elm-spa add static AboutUs')}
                             ${utils.bold('elm-spa add element Settings.Index')}


🌳  ${utils.bold('help')}                      print this help screen

                             examples:
                             ${utils.bold('elm-spa help')}
                             ${utils.bold('elm-spa wat')}
                             ${utils.bold('elm-spa huh?')}
                             ${utils.bold('elm-spa 🤷‍')}
`)

const init = ([ relative = '.' ] = []) => {
  const src = path.join(__dirname, 'initial-project')
  const dest = path.join(cwd, relative)
  if (fs.existsSync(dest)) fs.rmdirSync(dest)
  utils.cp(src, dest)
}

const add = ([ page, moduleName ] = []) => {
  const relative = '.'

  const expectedFiles = [
    path.join(cwd, relative, 'elm.json'),
    path.join(cwd, relative, 'src', 'Layouts')
  ]

  if (expectedFiles.some(file => !fs.existsSync(file))) {
    console.warn(`\n⚠️  I don't see an elm-spa project here... ⚠️\n\nPlease run this command in the directory with your ${utils.bold('elm.json')}\n`)
    return
  }

  const getLayouts = () =>
    utils.exploreFolder(path.join(cwd, relative, 'src', 'Layouts'))

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
⚠️  "${utils.bold(page)}" is not a valid page. ⚠️

Try one of these?
${utils.bold(Object.keys(isValidPage).map(page => `elm-spa add ${page} ${name}`).join('\n'))}
    `,
    invalidModuleName: ({ page, name }) => `
⚠️  "${utils.bold(name)}" doesn't look like an Elm module. ⚠️

Here are some examples of what I'm expecting:
${utils.bold(`elm-spa add ${page} Index`)}
${utils.bold(`elm-spa add ${page} Settings.User`)}
    `
  }

  if (isValidPage[page] !== true) {
    console.warn(messages.invalidPage({
      page,
      name: isValidModuleName(moduleName) ? moduleName : 'Index'
    }))
  } else if (isValidModuleName(moduleName) === false) {
    console.warn(messages.invalidModuleName({ page, name: moduleName }))
  } else {
    return getLayouts(relative)
      .then(layouts => 
        utils.sendToElm(relative)({
          command: 'add',
          page,
          path: moduleName.split('.'),
          layouts
        })
      )
  }
}

const build = (args = []) => {
  const optionArgs = args.filter(a => a.startsWith('--'))
  const nonOptionArgs = args.filter(a => a.startsWith('--') === false)
  const grabOption = (prefix) => (optionArgs.filter(option => option.startsWith(prefix))[0] || '').split(prefix)[1]

  const relative = nonOptionArgs.slice(-1)[0] || '.'
  const options = {
    ui: grabOption('--ui=') || 'Html'
  }

  return utils.exploreFolder(path.join(cwd, relative, 'src', 'Pages'))
    .then(pages => ({ command: 'build', pages, options }))
    .then(utils.sendToElm(relative))
}

// runs the things
main([...process.argv].slice(2))

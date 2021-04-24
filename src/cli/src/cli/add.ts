import path from "path"
import fs from "fs"
import config from "../config"
import * as File from '../file'
import { urlArgumentToPages } from "../templates/utils"
import Add from '../templates/add'
import { createMissingAddTemplates } from "./_common"


const bold = (str: string) => '\x1b[1m' + str + '\x1b[0m'
const cyan = (str: string) => '\x1b[36m' + str + '\x1b[0m'
const green = (str: string) => '\x1b[32m' + str + '\x1b[0m'
const yellow = (str: string) => '\x1b[33m' + str + '\x1b[0m'
const pink = (str: string) => '\x1b[35m' + str + '\x1b[0m'

// Scaffold a new elm-spa page
export default {
  run: async () => {
    let [ url, template ] = process.argv.slice(3)
    if (!url || url === '--help') {
      return Promise.reject(example)
    }
    const page = urlArgumentToPages(url)
    const outputFilepath = path.join(config.folders.pages.src, ...page ) + '.elm'
    let contents = Add(page)

    if (template) {
      const availableTemplates = await createMissingAddTemplates()
      const templateSrc = path.join(config.folders.templates.user, template + '.elm')

      contents = await File.read(templateSrc).catch(_ => Promise.reject(template404(url, template, availableTemplates)))
      contents = contents.split('{{module}}').join(page.join('.'))
    }
  
    await File.create(outputFilepath, contents)

    return `  ${bold('New page created at:')}\n  ${outputFilepath}\n`
  }
}

const example = '  ' + `
  ${bold(`elm-spa add`)} <url> [template]

  Examples:
  ${bold(`elm-spa ${cyan(`add`)}`)} ${yellow('/')} . . . . . . . . adds a homepage
  ${bold(`elm-spa ${cyan(`add`)}`)} ${yellow('/about-us')} . . . . adds a static route
  ${bold(`elm-spa ${cyan(`add`)}`)} ${yellow('/people/:id')} . . . adds a dynamic route

  Examples with templates:
  ${bold(`elm-spa ${cyan(`add`)}`)} ${yellow('/')} ${pink('static')}
  ${bold(`elm-spa ${cyan(`add`)}`)} ${yellow('/about-us')} ${pink('sandbox')}
  ${bold(`elm-spa ${cyan(`add`)}`)} ${yellow('/people/:id')} ${pink('element')}

  Visit ${green(`https://elm-spa.dev/guide/cli`)} for more details!
`.trim()

const template404 = (url : string, template : string, suggestions: string[]) => {
  const suggest = `
  Here are the available templates:

    ${suggestions.map(temp => `${yellow(`elm-spa add`)} ${yellow(url)} ${bold(pink(temp))}`).join('\n    ')}
  `

  return '  ' + `
  ${bold(`elm-spa`)} couldn't find a ${bold(pink(template))} template
  in the ${cyan('.elm-spa/templates')} folder.
  ${suggestions.length ? suggest : ''}
  Visit ${green(`https://elm-spa.dev/guide/cli`)} for more details!

`.trim()}
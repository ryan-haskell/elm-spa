import pkg from '../../package.json'

export default {
  run: () => helpText.trimLeft()
}

const bold = (str: string) => '\x1b[1m' + str + '\x1b[0m'
const cyan = (str: string) => '\x1b[36m' + str + '\x1b[0m'
const green = (str: string) => '\x1b[32m' + str + '\x1b[0m'
const yellow = (str: string) => '\x1b[33m' + str + '\x1b[0m'

const helpText = `
${bold(`elm-spa`)} – version ${yellow(pkg.version)}

Commands:
${bold(`elm-spa ${cyan(`new`)}`)} . . . . . . . . .  create a new project
${bold(`elm-spa ${cyan(`add`)}`)} <url> . . . . . . . . create a new page
${bold(`elm-spa ${cyan(`build`)}`)} . . . . . . one-time production build
${bold(`elm-spa ${cyan(`watch`)}`)} . . . . . . .  runs build as you code
${bold(`elm-spa ${cyan(`server`)}`)}  . . . . . . start a live dev server

Visit ${green(`https://elm-spa.dev`)} for more!
`
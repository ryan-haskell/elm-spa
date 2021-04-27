import path from "path"
import fs from "fs"
import config from "../config"
import * as File from '../file'
import { bold, check, colors, dim, dot, reset, warn } from "../terminal"
import { createInterface } from "readline"

// Scaffold a new elm-spa project
export default {
  run: async () => {
    return new Promise(offerToInitializeProject)
  }
}

const offerToInitializeProject = (resolve: (value: unknown) => void, reject: (reason: unknown) => void) => {
  const rl = createInterface({
    input: process.stdin,
    output: process.stdout
  })

  rl.question(`\n  May I create a ${colors.cyan}new project${reset} in the ${colors.yellow}current folder${reset}? ${dim}[y/n]${reset} `, answer => {
    if (answer.toLowerCase() === 'n') {
      reject(`  ${bold}No changes made!${reset}`)
    } else {
      resolve(initializeNewProject())
      rl.close()
    }
  })
}

const initializeNewProject = () => {
  const dest = process.cwd()
  File.copy(config.folders.init, dest)
  try { fs.renameSync(path.join(dest, '_gitignore'), path.join(dest, '.gitignore')) } catch (_) {}
  return `  ${check} ${bold}New project created in:${reset}\n  ${process.cwd()}\n`
}
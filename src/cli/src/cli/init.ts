import path from "path"
import fs from "fs"
import config from "../config"
import * as File from '../file'
import { bold, reset } from "../terminal"

// Scaffold a new elm-spa project
export default {
  run: () => {
    File.copy(config.folders.init, process.cwd())
    fs.mkdirSync(path.join(process.cwd(), 'src'))
    return `  ${bold}New project created in:${reset}\n  ${process.cwd()}`
  }
}
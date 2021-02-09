import path from "path"
import fs from "fs"
import config from "../config"
import * as File from '../file'
import { bold, reset } from "../terminal"

// Scaffold a new elm-spa project
export default {
  run: () => {
    const dest = process.cwd()
    File.copy(config.folders.init, dest)
    try { fs.renameSync(path.join(dest, '_gitignore'), path.join(dest, '.gitignore')) } catch (_) {}
    return `  ${bold}New project created in:${reset}\n  ${process.cwd()}`
  }
}
import path from "path"
import fs from "fs"
import config from "../config"
import * as File from '../file'
import { urlArgumentToPages } from "../templates/utils"
import Add from '../templates/add'
import { bold, reset } from "../terminal"

// Scaffold a new elm-spa page
export default {
  run: async () => {
    let url = process.argv[3]
    if (!url) {
      return Promise.reject(`${bold}elm-spa add${reset} requires a ${bold}url${reset} parameter!`)
    }
    const page = urlArgumentToPages(url)
    const filepath = path.join(config.folders.pages.src, ...page ) + '.elm'
    await File.create(filepath, Add(page))

    return `  ${bold}New page created at:${reset}\n  ${filepath}`
  }
}
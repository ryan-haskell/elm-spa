#!/usr/bin/env node

import CLI from './cli'
import { Commands } from './types'

const commands : Commands = {
  new: CLI.new,
  add: CLI.add,
  build: CLI.build,
  watch: CLI.watch,
  server: CLI.server,
  help: CLI.help
}

const command : string | undefined = process.argv[2]

Promise.resolve(command)
  .then(cmd => commands[cmd as keyof Commands] || commands.help)
  .then(task => task())
  .then(output => {
    const message = output instanceof Array ? output : [ output ]
    console.info('')
    console.info(message.join('\n\n'))
  })
  .catch(reason => {
    console.info('')
    console.error(reason)
    console.info('')
    process.exit(1)
  })
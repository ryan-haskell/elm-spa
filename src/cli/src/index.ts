#!/usr/bin/env node

import CLI from './cli'
import { dotElmSpa } from './config'
import { checkIfFolderExists } from './file'
import { Commands } from './types'

const commands: Commands = {
  new: CLI.new,
  add: CLI.add,
  build: CLI.build,
  gen: CLI.gen,
  watch: CLI.watch,
  server: CLI.server,
  help: CLI.help,
  // Aliases for Elm folks
  init: CLI.new,
  make: CLI.build,
}

const commandsNotRequiringInitialization = ['new', 'init', 'help']

const command: string | undefined = process.argv[2]

Promise.resolve(command)
  .then(async cmd =>  {
    if (!commandsNotRequiringInitialization.includes(cmd as string)) {
      if (!await checkIfFolderExists(dotElmSpa)) {
        throw '  This command must be run in a project folder containing a .elm-spa folder.'
      }
    }
    return cmd
  })
  .then(cmd => commands[cmd as keyof Commands] || commands.help)
  .then(task => task())
  .then(output => {
    const message = output instanceof Array ? output : [output]
    console.info('')
    console.info(message.join('\n\n'))
  })
  .catch(reason => {
    console.info('')
    console.error(reason)
    console.info('')
    process.exit(1)
  })

import New from './cli/init'
import Add from './cli/add'
import Build from './cli/build'
import Watch from './cli/watch'
import Server from './cli/server'
import Help from './cli/help'

export default {
  new: New.run,
  add: Add.run,
  build: Build.build,
  server: Server.run,
  gen: Build.gen,
  watch: Watch.run,
  help: Help.run,
  // Aliases for Elm folks
  init: New.run,
  make: Build.build,
}
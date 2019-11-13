const path = require('path')
const cwd = process.cwd()
const { File, Elm } = require('./utils.js')

const start = () =>
  File.paths(path.join(cwd, '..', 'examples', 'complex', 'src', 'Pages'))
    .then(Elm.run)
    .then(console.info)
    .catch(console.error)

start(process.argv.slice(2))
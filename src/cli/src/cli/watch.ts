import { build } from './build'
import chokidar from 'chokidar'
import config from '../config'

export const watch = () => {
  const runBuild = build('development')

  chokidar
    .watch(config.folders.src, { ignoreInitial: true })
    .on('all', () =>
      runBuild()
        .then(output => {
          console.info('')
          console.info(output)
        })
        .catch(reason => {
          console.info('')
          console.error(reason)
        })
    )

  return runBuild()
}

export default {
  run: watch
}
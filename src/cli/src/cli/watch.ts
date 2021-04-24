import { build } from './build'
import chokidar from 'chokidar'
import config from '../config'

export const watch = (runElmMake : boolean) => {
  const runBuild = build({ env: 'development', runElmMake })

  chokidar
    .watch(config.folders.src, { ignoreInitial: true })
    .on('all', () =>
      runBuild()
        .then(output => {
          console.info('')
          console.info(output)
          console.info('')
        })
        .catch(reason => {
          console.info('')
          console.error(reason)
          console.info('')
        })
    )

  return runBuild()
}

export default {
  run: () => watch(false)
}
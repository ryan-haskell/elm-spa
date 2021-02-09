import { exec } from 'child_process'

export const run = (cmd : string) : Promise<unknown> =>
  new Promise((resolve, reject) =>
    exec(cmd, (err, stdout, stderr) => err
      ? reject(stderr.split('npm ERR!')[0] || stderr)
      : resolve(stdout)
    )
  )
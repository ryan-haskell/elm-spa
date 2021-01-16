import { exec } from 'child_process'

export const run = (cmd : string) : Promise<unknown> =>
  new Promise((resolve, reject) =>
    exec(cmd, (err, stdout, stderr) => err ? reject(stderr) : resolve(stdout))
  )
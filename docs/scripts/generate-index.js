const fs = require('fs').promises
const path = require('path')

const config = {
  content: path.join(__dirname, '..', 'public', 'content'),
  output: path.join(__dirname, '..', 'public', 'dist')
}

// Recursively lists all files in the given folder
const listContainedFiles = async (folder) => {
  let files = []
  const items = await fs.readdir(folder)

  await Promise.all(items.map(async item => {
    const filepath = path.join(folder, item)
    const stat = await fs.stat(filepath)
    if (stat.isDirectory()) {
      const innerFiles = await listContainedFiles(filepath)
      files = files.concat(innerFiles)
    } else {
      files.push(filepath)
    }
  }))

  return files
} 

// The entrypoint to my script
const main = () =>
  listContainedFiles(config.content)
    .then(files =>
      Promise.all(files.map(async f => {
        const url = f.substring(config.content.length, f.length - '.md'.length)
        const content = await fs.readFile(f, { encoding: 'utf-8' })
        const headers =
          content.split('\n')
            .reduce((acc, line) => {
              if (line.startsWith('# ')) {
                acc[line.substring(2)] = 1
              } else if (line.startsWith('## ')) {
                acc[line.substring(3)] = 2
              } else if (line.startsWith('### ')) {
                acc[line.substring(4)] = 3
              }

              return acc
            }, {})

        return { url, headers }
    }))
    )
    .then(json => `window.__FLAGS__ = ${JSON.stringify(json, null, 2)}`)
    .then(async contents => {
      await fs.mkdir(config.output, { recursive: true })
      return fs.writeFile(path.join(config.output, 'flags.js'), contents, { encoding: 'utf-8' })
    })
    .then(_ => console.info(`\n  ✓ Indexed the content folder\n`))
    .catch(console.error)

// Run the program
main()
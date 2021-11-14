import { promises as fs } from 'fs'
import oldFs from 'fs'
import path from "path"

/**
 * Create a new file, creating the containing folder if missing.
 * @param filepath - the absolute path of the file to create
 * @param contents - the raw string contents of the file
 */
export const create = async (filepath: string, contents: string) => {
  await ensureFolderExists(filepath)
  return fs.writeFile(filepath, contents, { encoding: 'utf8' })
}

/**
 * Removes a file or folder at the given path.
 * @param filepath - the path of the file or folder to remove
 */
export const remove = async (filepath: string) => {
  const stats = await fs.stat(filepath)
  return stats.isFile()
    ? fs.unlink(filepath)
    : fs.rmdir(filepath, { recursive: true })
}

export const scan = async (dir: string, extension = '.elm'): Promise<string[]> => {
  const doesExist = await exists(dir)
  if (!doesExist) return Promise.resolve([])
  const items = await ls(dir)
  const [folders, files] = await Promise.all([
    keepFolders(items),
    Promise.resolve(items.filter(f => f.endsWith(extension)))
  ])
  const listOfFiles = await Promise.all(folders.map(f => scan(f, extension)))
  const nestedFiles = listOfFiles.reduce((a, b) => a.concat(b), [])
  return Promise.resolve(files.concat(nestedFiles))
}

const ls = (dir: string): Promise<string[]> =>
  fs.readdir(dir)
    .then(data => data.map(p => path.join(dir, p)))

const isDirectory = (dir: string): Promise<boolean> =>
  fs.lstat(dir).then(data => data.isDirectory()).catch(_ => false)

const keepFolders = async (files: string[]): Promise<string[]> => {
  const possibleFolders = await Promise.all(
    files.map(f => isDirectory(f).then(isDir => isDir ? f : undefined))
  )
  return possibleFolders.filter(a => a !== undefined) as string[]
}

export const exists = (filepath: string) =>
  fs.stat(filepath)
    .then(_ => true)
    .catch(_ => false)



/**
 * Copy the file or folder at the given path.
 * @param filepath - the path of the file or folder to copy
 */
export const copy = (src: string, dest: string) => {
  const exists = oldFs.existsSync(src)
  const stats = exists && oldFs.statSync(src)
  if (stats && stats.isDirectory()) {
    try { oldFs.mkdirSync(dest, { recursive: true }) } catch (_) { }
    oldFs.readdirSync(src).forEach(child =>
      copy(path.join(src, child), path.join(dest, child))
    )
  } else {
    oldFs.copyFileSync(src, dest)
  }
}

export const copyFile = async (src: string, dest: string) => {
  await ensureFolderExists(dest)
  return fs.copyFile(src, dest)
}


const ensureFolderExists = async (filepath: string) => {
  const folder = filepath.split(path.sep).slice(0, -1).join(path.sep)
  return fs.mkdir(folder, { recursive: true })
}

export const mkdir = (folder: string): Promise<string> =>
  fs.mkdir(folder, { recursive: true })

export const read = async (path: string) =>
  fs.readFile(path, { encoding: 'utf-8' })

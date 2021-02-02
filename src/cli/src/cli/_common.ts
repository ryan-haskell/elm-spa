import config from "../config"
import * as File from '../file'

export const createMissingAddTemplates = async () => {
  const folderAlreadyExists = await File.exists(config.folders.templates.user)
  if (folderAlreadyExists === false) {
    File.copy(config.folders.templates.defaults, config.folders.templates.user)
  }

  return (await File.scan(config.folders.templates.user))
    .map(fp => fp.substring(config.folders.templates.user.length + 1, fp.length - 4))
}
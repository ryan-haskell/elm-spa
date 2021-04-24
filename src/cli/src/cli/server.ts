import chokidar from "chokidar"
import Url from 'url'
import http from 'http'
import websocket, { connection } from 'websocket'
import path from 'path'
import * as File from "../file"
import { watch } from './watch'
import { colors, reset } from "../terminal"
import mime from 'mime'
import { createReadStream } from "fs"

const start = async () => new Promise((resolve, reject) => {
  const config = {
    port: process.env.PORT || 1234,
    base: path.join(process.cwd(), 'public'),
    index: 'index.html'
  }

  const contentType = (extension : string) : string =>
    mime.getType(extension) || 'text/plain'

  const server = http.createServer(async (req, res) => {
    const url = Url.parse(req.url || '')
    const error = () => {
      res.statusCode = 404
      res.setHeader('Content-Type', 'text/plain')
      res.write('File not found.')
      res.end()
    }
    if ((url.pathname || '').includes('.')) {
      try {
        const filepath = path.join(config.base, ...(url.pathname || '').split('/'))
        const s = createReadStream(filepath)
        s.on('open', () => {
          const extension = (url.pathname || '').split('.').slice(-1)[0]
          res.setHeader('Content-Type', contentType(extension))
          s.pipe(res)
        })
        s.on('error', error)
      } catch (_) { error() }
    } else {
      let file = await File.read(path.join(config.base, config.index))
      file = file.split('</body>').join(`  <script>${script}</script>\n</body>`)
      res.setHeader('Content-Type', contentType('html'))
      res.write(file)
      res.end()
    }
  })

  // Websockets for live-reloading
  const connections : { [key: string]: connection } = {}
  const ws = new websocket.server({ httpServer: server })
  const script = ` new WebSocket('ws://' + window.location.host, 'elm-spa').onmessage = function () { window.location.reload() } `
  ws.on('request', (req) => {
    const conn = req.accept('elm-spa', req.origin)
    connections[req.remoteAddress] = conn
    conn.on('close', () => delete connections[conn.remoteAddress])
  })
  
  // Send reload if any files change
  chokidar.watch(config.base, { ignoreInitial: true })
    .on('all', () => Object.values(connections).forEach(conn => conn.sendUTF('reload')))

  // Start server
  server.listen(config.port, () => resolve(`Ready at ${colors.cyan}http://localhost:${config.port}${reset}`))
  server.on('error', _ => {
    reject(`Unable to start server... is port ${config.port} in use?`)
  })
})

export default {
  run: async () => {
    const output = await watch(true)
    return start().then(serverOutput => [ serverOutput, output ])
  }
}
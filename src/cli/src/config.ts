import path from 'path'

const reserved = {
  homepage: 'Home_',
  notFound: 'NotFound'
}

const root = path.join(__dirname, '..', '..')
const cwd = process.cwd()

const config = {
  reserved,
  folders: {
    init: path.join(root, 'src', 'new'),
    src: path.join(cwd, 'src'),
    pages: {
      src: path.join(cwd, 'src', 'Pages'),
      defaults: path.join(cwd, '.elm-spa', 'defaults', 'Pages')
    },
    defaults: {
      src: path.join(root, 'src', 'defaults'),
      dest: path.join(cwd, '.elm-spa', 'defaults')
    },
    generated: path.join(cwd, '.elm-spa', 'generated'),
    package: path.join(cwd, '.elm-spa', 'package'),
    public: path.join(cwd, 'public'),
    dist: path.join(cwd, 'public', 'dist'),
  },
  binaries: {
    elm: `npx elm`,
    terser: `npx terser`
  },
  defaults: [
    [ 'Main.elm' ],
    [ 'Shared.elm' ],
    [ `Pages`, `${reserved.notFound}.elm` ],
    [ 'Page.elm' ],
    [ 'Request.elm' ],
    [ 'View.elm' ]
  ]
}

export default config
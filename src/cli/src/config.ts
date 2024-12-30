import path from 'path'

const reserved = {
  homepage: 'Home_',
  redirecting: 'Redirecting_',
  notFound: 'NotFound'
}

const root = path.join(__dirname, '..', '..')
const cwd = process.cwd()
export const dotElmSpa = path.join(cwd, '.elm-spa');

const config = {
  reserved,
  folders: {
    init: path.join(root, 'src', 'new'),
    src: path.join(cwd, 'src'),
    pages: {
      src: path.join(cwd, 'src', 'Pages'),
      defaults: path.join(dotElmSpa, 'defaults', 'Pages')
    },
    defaults: {
      src: path.join(root, 'src', 'defaults'),
      dest: path.join(dotElmSpa, 'defaults')
    },
    generated: path.join(dotElmSpa, 'generated'),
    templates: {
      defaults: path.join(root, 'src', 'templates', 'add'),
      user: path.join(dotElmSpa, 'templates')
    },
    package: path.join(dotElmSpa, 'package'),
    public: path.join(cwd, 'public'),
    dist: path.join(cwd, 'public', 'dist'),
  },
  defaults: [
    [ 'Auth.elm' ],
    [ 'Effect.elm' ],
    [ 'Main.elm' ],
    [ 'Shared.elm' ],
    [ `Pages`, `${reserved.notFound}.elm` ],
    [ 'View.elm' ]
  ]
}

export default config
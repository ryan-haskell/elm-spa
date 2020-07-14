// Initial data to pass in to Elm (linked with `Shared.Flags`)
// https://guide.elm-lang.org/interop/flags.html
const isLocalDevelopment = window.location.hostname === 'localhost'

const Storage = {
  save: (key, value) => localStorage.setItem(key, JSON.stringify(value)),
  load: (key) => JSON.parse(localStorage.getItem(key))
}

const flags = {
  production: { githubClientId: '2a8238fe92e1e04c9af2' },
  dev: { githubClientId: '20c33fe428b932816bb2' }
}

// Start our Elm application
const app = Elm.Main.init({
  flags: {
    ...(isLocalDevelopment ? flags.dev : flags.production),
    token: Storage.load('user')
  }
})

// Ports would go here: https://guide.elm-lang.org/interop/ports.html
app.ports.storeToken.subscribe(token => Storage.save('user', token))
app.ports.clearToken.subscribe(_ => Storage.save('user', null))
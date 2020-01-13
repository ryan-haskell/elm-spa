// On load, listen to Elm!
window.addEventListener('load', _ => {
  window.ports = {
    init: (app) =>
      app.ports.outgoing.subscribe(({ action, data }) =>
        actions[action]
          ? actions[action](data)
          : console.warn(`I didn't recognize action "${action}".`)
      )
  }
})

// maps actions to functions!
const actions = {
  'LOG': (message) =>
    console.log(`From Elm:`, message)
}

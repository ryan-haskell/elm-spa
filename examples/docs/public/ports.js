const Ports = {
  // Called by index.html
  init: (app) => {
    if (app.ports && app.ports.outgoing) {
      app.ports.outgoing.subscribe(({ action, data }) =>
        Ports.actions[action]
          ? Ports.actions[action](data)
          : console.warn(`I didn't recognize action "${action}".`)
      )
    }
  },
  // Maps an action name to its handler
  actions: {
    'LOG': (message) =>
      console.info(`From Elm:`, message)
  }
}
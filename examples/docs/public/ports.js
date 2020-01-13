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
    'SCROLL_TO_TOP': _ =>
      window.scroll({ top: 0, left: 0, behavior: 'smooth' })
  }
}
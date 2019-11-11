const SCROLL_TO = (id) =>
  document.getElementById(id) &&
    window.scrollTo({
      top: document.getElementById(id).offsetTop,
      left: 0,
      behavior: "smooth"
    })

window.addEventListener("load", () => {
  window.ports = {
    init: (app) => {
      app.ports.outgoing.subscribe(({ action, data }) => {
        const actions = {
          SCROLL_TO
        }

        if (actions[action]) {
          actions[action](data)
        } else {
          console.warn(
            `I didn't recognize action "${action}". Check out ./public/ports.js`
          )
        }
      })
    }
  }
})

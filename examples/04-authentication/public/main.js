const app = Elm.Main.init({
  flags: JSON.parse(localStorage.getItem('storage'))
})

app.ports.save_.subscribe(storage => {
  localStorage.setItem('storage', JSON.stringify(storage))
  app.ports.load_.send(storage)
})
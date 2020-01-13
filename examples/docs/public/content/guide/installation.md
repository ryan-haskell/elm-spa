---
{ "title": "installing things"
, "description": "getting your computer ready to roll."
}
---

<iframe></iframe>

### what's in this section?

Together, we're going to:

1. install node
1. install elm via npm
1. install your text editor

### installing node

Installing NodeJS from [nodejs.org](https://nodejs.org/) will allow us to run `npm` commands from our terminal or command prompt.

Make sure to get the latest LTS release (at the time of writing this, that was `12.13.1 LTS`)

#### did it work?

You can confirm that node is installed by running this command

```bash
npm -v
```

(that should spit out a number like `6.11.3`, though it doesn't need to that exact number)

### installing all the elm things

We can use `npm` to install `elm` and a few other tools.

```bash
npm install -g elm elm-format elm-live elm-spa
```

These things will be useful for running commands in the terminal, and help us with the next section!

### installing a text editor

There's plenty of choices out there, but for this guide I'll be using:

- [VS Code](https://code.visualstudio.com/)

Once you have that installed, we can start getting our Elm dev environment
setup!

Install the [Elm](https://marketplace.visualstudio.com/items?itemName=Elmtooling.elm-ls-vscode) extension so we get syntax highlighting and
magical format-on-save technology!

You can run `Ctrl+Shift+P` in VS code to add these settings to your user settings:

```js
{
  // ...
  "[elm]": {
      "editor.formatOnSave": true,
      "editor.tabSize": 4
  }
}
```

That's it! You're ready for the next section!
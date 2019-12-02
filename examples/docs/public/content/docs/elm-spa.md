---
{ "title": "elm-spa cli"
, "description": "a command line tool."
}
---

<iframe></iframe>

### using elm-spa

If you have the latest [NodeJS](https://nodejs.org) installed, you already have the `npx` command.

```bash
npx elm-spa help
```

The docs and guide use `npx`, because it has less issues than doing a global installation
with the `--global` flag.

### installing elm-spa

If you would rather just run `elm-spa` without the `npx` prefix, you can run this
command:

```bash
npm install --global elm-spa
```

And if you don't receive any permissions issues, that's it! If you do, [this NPM article](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally)
may be useful for you.

Running `elm-spa help` should now work too!

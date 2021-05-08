# elm-spa cli
> the command-line interface for __elm-spa__

## installation

```bash
npm install -g elm-spa@latest
```

## usage

```
$ elm-spa help
```
```
elm-spa – version 6.0.4

Commands:
elm-spa new . . . . . . . . .  create a new project
elm-spa add <url> . . . . . . . . create a new page
elm-spa build . . . . . . one-time production build
elm-spa server  . . . . . . start a live dev server

Other commands:
elm-spa gen . . . . generates code without elm make
elm-spa watch . . . .  runs elm-spa gen as you code

Visit https://elm-spa.dev for more!
```

## learn more

Check out the official guide at https://elm-spa.dev!

# contributing

The CLI is written with TypeScript + NodeJS. Here's how you can get started contributing:

```bash
npm start       # first time dev setup
```

```bash
npm run dev     # compiles as you code
npm run build   # one-time production build
npm run test    # run test suite
```

## playing with the CLI locally

Here's how you can make the `elm-spa` command work with your local build of this
repo.

```bash
npm remove -g elm-spa   # remove any existing `elm-spa` installs
npm link                # make `elm-spa` refer to our local code
```
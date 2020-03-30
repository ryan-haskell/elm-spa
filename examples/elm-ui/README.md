# examples/elm-ui

```
npm start
```

## how i upgraded to elm-ui

```
npm install -g elm-spa
elm-spa init my-project
cd my-project
elm install mdgriffith/elm-ui
```

Checkout the `src/Page.elm` and `src/Document.elm` files, they allow us to create pages with `Element msg` and `Html msg`

From there, I just replaced `Html` with `Element` in the `src/Pages/*.elm` files.
# your elm-spa
> learn more at [https://elm-spa.dev](https://elm-spa.dev)

### local development

```
npm run dev
```

## folder structure

```elm
README.md          -- this file you're reading 👀
elm.json           -- has project dependencies
src/
  Main.elm         -- the entrypoint to the app
  Global.elm       -- share state across pages
  Transitions.elm  -- smoothly animate between pages
  Ports.elm        -- communicate with JS
  Pages/           -- where all your pages go
  Layouts/         -- reusable views around pages
  Components/      -- views shared across the site
  Utils/           -- a place for helper functions
```
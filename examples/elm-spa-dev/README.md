# new elm-spa project
> More documentation at https://elm-spa.dev

## local development

You can get this site up and running with one command:

```
npm start
```

### other commands to know

There are a handful of commands in the [package.json](./package.json).

Command | Description
:-- | :--
`npm run dev` | Run a dev server and automatically build changes.
`npm run test:watch` | Run tests as you code.
`npm run build` | Build the site for production.
`npm run test` | Run the test suite once, great for CI


## deploying

After you run `npm run build`, the contents of the `public` folder can be hosted as a static site. If you haven't hosted a static site before, I'd recommend using [Netlify](https://netlify.com) (it's free!)

### using netlify

Add a `netlify.toml` file next to this README, for standard SPA routing:

```toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```
 
__Build command:__ `npm run build`

__Publish directory:__ `public`
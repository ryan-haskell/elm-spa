# API
> Using Netlify Functions to authenticate with GitHub

There are important client secrets that I can't push to source control. For that reason, we'll need add API keys manually.

## local development

First, create a file called `~/api/config/secrets.js`

You'll need to [create an GitHub application](https://github.com/settings/applications/new) and
copy your __Client ID__ and __Client Secret__ here.

```js
module.exports = {
  clientId: '<your-client-id>',
  clientSecret: '<your-client-secret>'
}
```

You'll also need to edit `flags.dev.githubClientId` in `~/public/main.js`:

```js
const flags = {
  production: { githubClientId: '2a8238fe92e1e04c9af2' },
  dev: { githubClientId: '<your-client-id>' }
}
```
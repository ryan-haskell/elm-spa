const fs = require('fs')
const path = require('path')

const filesInGuideFolder =
  fs.readdirSync(path.join(__dirname, 'public/content/guide'))

const routes =
  [ '/',
    '/guide',
    '/examples',
    ...(
      filesInGuideFolder
        .map(file => '/guide/' + file.split('.md')[0])
    )
  ]

Promise.resolve(routes)
  .then(routes => routes.map(route =>`<url><loc>https://www.elm-spa.dev${route}</loc></url>`))
  .then(entries => `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ${entries.join('\n  ')}
</urlset>`)
  .then(content => fs.writeFileSync(path.join(__dirname, 'public', 'dist', 'sitemap.xml'), content, { encoding: 'utf-8' }))
  .then(console.log)
  .catch(console.error)
#!/usr/bin/env node
const fs = require('fs')
const path = require('path')
const cwd = process.cwd()

const main = ([ command, ...args ] = []) => {
  const commands = {
    help: _ => console.log('help'),
    run: generate,
    generate: generate
  }

  return (commands[command] || commands['help'])(args || [])
}

const generate = ([ relative = '.' ]) => {
  const { template, folders} = explore(path.join(cwd, relative))
  fs.mkdirSync(path.join(cwd, relative, 'src', 'Generated'), { recursive: true })
  fs.writeFileSync(path.join(cwd, relative, 'src', 'Generated', 'Pages.elm'), template, { encoding: 'utf8' })
}

const explore = (dir) => {
  const src = path.join(dir, 'src')
  const dirs = {
    pages: path.join(src, 'Pages')
  }
  const contents = fs.readdirSync(dirs.pages)
  const hasDot = a => a.indexOf('.') !== -1
  const files = contents.filter(hasDot).map(a => a.split('.')[0])
  const folders = contents.filter(a => !hasDot(a))
  return {
    template: templates.pages({ files, folders }),
    folders
  }
}

const camelCase = (name) =>
  name[0].toLowerCase() + name.slice(1)

const sluggify = (name) =>
  name.split('')
    .map(a => a === a.toUpperCase() ? '-' + a : a)
    .join('').slice(1).toLowerCase()

const templates = {
  pages: ({ files, folders }) => {
    const items = files.concat(folders)

    const customType = (name) =>
      (items.length > 0)
        ? `type ${name}\n    = ${items.map(item => `${item}${name} ${item}.${name}`).join('\n    | ')}`
        : ''

    const recipes = () =>
      (items.length > 0)
        ? items.map(name => {
            const variable = camelCase(name)
            return `${variable} : Application.Recipe ${name}.Route ${name}.Model ${name}.Msg Model Msg
${variable} =
    ${name}.page
        { toModel = ${name}Model
        , toMsg = ${name}Msg
        }`
        }).join('\n\n\n')
        : ''

    const routes = () => {
      const formatter = {
        Index: name => `Route.index IndexRoute`
      }
      

      return (items.length > 0)
        ? `routes : Application.Routes Route
routes =
    [ ${files.map(name => formatter[name]
        ? formatter[name](name)
        : `Route.path "${sluggify(name)}" ${name}Route`
      ).join('\n    , ')}
    ${folders.length
      ? `, ${folders.map(name => `Route.folder "${sluggify(name)}" ${name}Route ${name}.routes`).join('\n    , ') + '\n    '}`
      : ''}]`
        : ''
    }

    const caseOf = ({ name, types, inputs, branch }) =>
      `${name} : ${types.input} -> ${types.output}
${name} ${inputs} =
    case ${branch.input} of
${items
            .map(name => `        ${branch.condition(name)} ->
            ${branch.result(name)}`).join('\n\n')}`

    return `module Generated.Pages exposing
    ( Model
    , Msg
    , Route(..)
    , bundle
    , init
    , routes
    , update
    )

import Application
import Application.Route as Route
${folders.map(name => `import Generated.Pages.${name} as ${name}`).join('\n')}
${files.map(name => `import Pages.${name} as ${name}`).join('\n')}



-- ROUTES


${customType('Route')}


${routes()}



-- MODEL & MSG


${customType('Model')}


${customType('Msg')}



-- RECIPES


${recipes()}



-- INIT


${caseOf({
  name: 'init',
  types: {
    input: 'Route',
    output: 'Application.Init Model Msg'
  },
  inputs: 'route_',
  branch: {
    input: 'route_',
    condition: name => `${name}Route route`,
    result: name => `${camelCase(name)}.init route`
  }
})}



-- UPDATE


${caseOf({
  name: 'update',
  types: {
    input: 'Msg -> Model',
    output: '( Model, Cmd Msg )'
  },
  inputs: 'msg_ model_',
  branch: {
    input: '( msg_, model_ )',
    condition: name => `( ${name}Msg msg, ${name}Model model )`,
    result: name => `${camelCase(name)}.update msg model`,
  }
})}
        _ ->
            Application.keep model_


-- BUNDLE


${caseOf({
  name: 'bundle',
  types: {
    input: 'Model',
    output: 'Application.Bundle Msg'
  },
  inputs: 'model_',
  branch: {
    input: 'model_',
    condition: name => `${name}Model model`,
    result: name => `${camelCase(name)}.bundle model`,
  }
})}
`
  }
}


main([...process.argv].slice(2))
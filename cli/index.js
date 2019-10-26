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
            return `${variable} : Page.Recipe Route.${name}Params ${name}.Model ${name}.Msg Model Msg Global.Model Global.Msg a
${variable} =
    ${name}.page
        { toModel = ${name}Model
        , toMsg = ${name}Msg
        }`
        }).join('\n\n\n')
        : ''

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
    , bundle
    , init
    , update
    )

import Application.Page as Page
import Generated.Route as Route exposing (Route)
${folders.map(name => `import Generated.Pages.${name} as ${name}`).join('\n')}
import Global
${files.map(name => `import Pages.${name} as ${name}`).join('\n')}



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
    output: 'Page.Init Model Msg Global.Model Global.Msg'
  },
  inputs: 'route_',
  branch: {
    input: 'route_',
    condition: name => `Route.${name} route`,
    result: name => `${camelCase(name)}.init route`
  }
})}



-- UPDATE


${caseOf({
  name: 'update',
  types: {
    input: 'Msg -> Model',
    output: 'Page.Update Model Msg Global.Model Global.Msg'
  },
  inputs: 'msg_ model_',
  branch: {
    input: '( msg_, model_ )',
    condition: name => `( ${name}Msg msg, ${name}Model model )`,
    result: name => `${camelCase(name)}.update msg model`,
  }
})}
        _ ->
            Page.keep model_


-- BUNDLE


${caseOf({
  name: 'bundle',
  types: {
    input: 'Model',
    output: 'Page.Bundle Msg Global.Model Global.Msg a'
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
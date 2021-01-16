import config from '../../src/config'
import * as Utils from '../../src/templates/utils'

describe("Templates.Utils", () => {

  test.each([
    [ '/', [ 'Home_' ] ],
    [ '/about-us', [ 'AboutUs' ] ],
    [ '/people/:name', [ 'People', 'Name_' ] ],
    [ '/users/:name/posts/:id', [ 'Users', 'Name_', 'Posts', 'Id_' ] ],
    [ 'Pages.AboutUs', [ 'AboutUs' ] ],
    [ 'Pages/AboutUs.elm', [ 'AboutUs' ] ],
    [ 'Pages.People.Name_', [ 'People', 'Name_' ] ],
    [ 'People.Name_', [ 'People', 'Name_' ] ],
    [ 'Pages/People/Name_.elm', [ 'People', 'Name_' ] ],
    [ 'People/Name_.elm', [ 'People', 'Name_' ] ],
    [ 'Home_', [ 'Home_' ] ],
    [ 'Pages.Home_', [ 'Home_' ] ],
    [ 'Home_.elm', [ 'Home_' ] ],
    [ 'Pages/Home_.elm', [ 'Home_' ] ],
  ])(".urlArgumentToPages(%p)", (input, output) => {
    expect(Utils.urlArgumentToPages(input)).toEqual(output)
  })

  test.each([
    [ [ config.reserved.homepage ], config.reserved.homepage ],
    [ [ "AboutUs" ], "AboutUs" ],
    [ [ "AboutUs", "Offices" ], "AboutUs__Offices" ],
    [ [ "Posts" ], "Posts" ],
    [ [ "Posts", "Id_" ], "Posts__Id_" ],
    [ [ "Users", "Name_", "Settings" ], "Users__Name___Settings" ],
    [ [ "Users", "Name_", "Posts", "Id_" ], "Users__Name___Posts__Id_" ],
  ])(".routeVariant(%p)", (input, output) => {
    expect(Utils.routeVariant(input)).toBe(output)
  })

  test.each([
    [ [ config.reserved.homepage ], `()` ],
    [ [ "AboutUs" ], "()" ],
    [ [ "AboutUs", "Offices" ], "()" ],
    [ [ "Posts" ], "()" ],
    [ [ "Posts", "Id_" ], "{ id : String }" ],
    [ [ "Users", "Name_", "Settings" ], "{ name : String }" ],
    [ [ "Users", "Name_", "Posts", "Id_" ], "{ name : String, id : String }" ],
  ])(".routeParameters(%p)", (input, output) => {
    expect(Utils.routeParameters(input)).toBe(output)
  })

  test.each([
    [ [ config.reserved.homepage ], `(Parser.top)` ],
    [ [ "AboutUs" ], `(Parser.s "about-us")` ],
    [ [ "AboutUs", "Offices" ], `(Parser.s "about-us" </> Parser.s "offices")` ],
    [ [ "Posts" ], `(Parser.s "posts")` ],
    [ [ "Posts", "Id_" ], `Parser.map Params (Parser.s "posts" </> Parser.string)` ],
    [ [ "Users", "Name_", "Settings" ], `Parser.map Params (Parser.s "users" </> Parser.string </> Parser.s "settings")` ],
    [ [ "Users", "Name_", "Posts", "Id_" ], `Parser.map Params (Parser.s "users" </> Parser.string </> Parser.s "posts" </> Parser.string)` ],
  ])(".routeParser(%p)", (input, output) => {
    expect(Utils.routeParser(input)).toBe(output)
  })

  test.each([
    [ [ config.reserved.homepage ],         `Parser.map ${config.reserved.homepage} Gen.Params.${config.reserved.homepage}.parser` ],
    [ [ `AboutUs` ],                        `Parser.map AboutUs Gen.Params.AboutUs.parser` ],
    [ [ `AboutUs`, `Offices` ],             `Parser.map AboutUs__Offices Gen.Params.AboutUs.Offices.parser` ],
    [ [ `Posts` ],                          `Parser.map Posts Gen.Params.Posts.parser` ],
    [ [ `Posts`, `Id_` ],                   `Parser.map Posts__Id_ Gen.Params.Posts.Id_.parser` ],
    [ [ `Users`, `Name_`, `Settings` ],     `Parser.map Users__Name___Settings Gen.Params.Users.Name_.Settings.parser` ],
    [ [ `Users`, `Name_`, `Posts`, `Id_` ], `Parser.map Users__Name___Posts__Id_ Gen.Params.Users.Name_.Posts.Id_.parser` ]
  ])(".routeFunction(%p)", (input, output) => {
    expect(Utils.routeParserMap(input)).toBe(output)
  })

  test.each([
    [ [], `[]`,
      [ '1' ], `
[ 1
]
        `.trim(),
      [ '1', '2', '3' ], `
[ 1
, 2
, 3
]
    `.trim()
    ]
  ])(`.multilineList(%p)`, (input, output) => {
    expect(Utils.multilineList(input)).toBe(output)
  })

  test(`.indent([ 1, 2, 3 ])`, () => {
    expect(Utils.indent(Utils.multilineList([ '1', '2', '3' ]))).toBe(`
    [ 1
    , 2
    , 3
    ]`.substr(1))
  })

  test(`.indent([ 1, 2, 3 ], 2)`, () => {
    expect(Utils.indent(Utils.multilineList([ '1', '2', '3' ]), 2)).toBe(`
        [ 1
        , 2
        , 3
        ]`.substr(1))
  })

  test(".customType(%p)", () => {
    expect(Utils.customType(`Color`, [ `Red`, `Green`, `Blue`, `Other String` ]))
      .toBe(`
type Color
    = Red
    | Green
    | Blue
    | Other String
      `.trim())
  })

  test(`.routeTypeDefinition`, () => {
    expect(Utils.routeTypeDefinition([
      [ config.reserved.homepage ],
      [ 'AboutUs' ],
      [ 'Users', 'Name_' ],
      [ 'Settings', 'Section_', 'New' ]
    ])).toBe(`
type Route
    = ${config.reserved.homepage}
    | AboutUs
    | Users__Name_ { name : String }
    | Settings__Section___New { section : String }
    `.trim())
  })

  test(`.routeParserList`, () => {
    expect(Utils.routeParserList([
      [ config.reserved.homepage ],
      [ 'AboutUs' ],
      [ 'Users', 'Name_' ],
      [ 'Settings', 'Section_', 'New' ]
    ])).toBe(`
[ Parser.map ${config.reserved.homepage} Gen.Params.${config.reserved.homepage}.parser
, Parser.map AboutUs Gen.Params.AboutUs.parser
, Parser.map Users__Name_ Gen.Params.Users.Name_.parser
, Parser.map Settings__Section___New Gen.Params.Settings.Section_.New.parser
]
    `.trim())
  })
})
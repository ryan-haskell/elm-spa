module Templates.TopLevelPages exposing (contents)

import Item exposing (Item)
import Templates.Shared as Shared


contents : List Item -> String
contents items =
    """module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page exposing (Page)
{{folderImports}}
import Generated.Route as Route exposing (Route)
import Global
import Layouts.Main as Layout
{{fileImports}}



-- MODEL & MSG


{{models}}


{{msgs}}


page : Page Route Model Msg a b Global.Model Global.Msg c
page =
    Page.layout
        { view = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }



-- RECIPES


{{recipes}}



-- INIT


{{init}}



-- UPDATE


{{update}}

        _ ->
            Page.keep model_



-- BUNDLE


{{bundle}}

"""
        |> String.replace "{{fileImports}}" (fileImports items)
        |> String.replace "{{folderImports}}" (folderImports items)
        |> String.replace "{{models}}" (Shared.customTypes "Model" items)
        |> String.replace "{{msgs}}" (Shared.customTypes "Msg" items)
        |> String.replace "{{recipes}}" (recipes items)
        |> String.replace "{{init}}"
            (topLevelFunction
                { name = "init"
                , types =
                    { input = "Route"
                    , output = "Page.Init Model Msg Global.Model Global.Msg"
                    }
                , inputs = "route_"
                , caseExpression =
                    { value = "route_"
                    , condition = \name -> String.concat [ "Route.", name, " route" ]
                    , result = \name -> String.concat [ camelCase name, ".init route" ]
                    }
                }
                items
            )
        |> String.replace "{{update}}"
            (topLevelFunction
                { name = "update"
                , types =
                    { input = "Msg -> Model"
                    , output = "Page.Update Model Msg Global.Model Global.Msg"
                    }
                , inputs = "msg_ model_"
                , caseExpression =
                    { value = "( msg_, model_ )"
                    , condition = \name -> String.concat [ "( ", name, "Msg msg, ", name, "Model model )" ]
                    , result = \name -> String.concat [ camelCase name, ".update msg model" ]
                    }
                }
                items
            )
        |> String.replace "{{bundle}}"
            (topLevelFunction
                { name = "bundle"
                , types =
                    { input = "Model"
                    , output = "Page.Bundle Msg Global.Model Global.Msg a"
                    }
                , inputs = "model_"
                , caseExpression =
                    { value = "model_"
                    , condition = \name -> String.concat [ name, "Model model" ]
                    , result = \name -> String.concat [ camelCase name, ".bundle model" ]
                    }
                }
                items
            )


{-| fileImports

    import Pages.Counter as Counter
    import Pages.Index as Index
    import Pages.NotFound as NotFound
    import Pages.Random as Random
    import Pages.SignIn as SignIn

-}
fileImports : List Item -> String
fileImports items =
    Item.files items
        |> List.map (\file -> String.concat [ "import Pages.", file.name, " as ", file.name ])
        |> String.join "\n"


{-| folderImports

    import Generated.Pages.Settings as Settings
    import Generated.Pages.Users as Users

-}
folderImports : List Item -> String
folderImports items =
    Item.folders items
        |> List.map (\folder -> String.concat [ "import Generated.Pages.", folder.name, " as ", folder.name ])
        |> String.join "\n"


recipes : List Item -> String
recipes items =
    items
        |> List.map Item.name
        |> List.map recipe
        |> String.join "\n\n\n"


{-| recipe "Counter"

    counter : Page.Recipe Route.CounterParams Counter.Model Counter.Msg Model Msg Global.Model Global.Msg msg
    counter =
        Counter.page
            { toModel = CounterModel
            , toMsg = CounterMsg
            }

-}
recipe : String -> String
recipe name =
    """{{camelCase}} : Page.Recipe Route.{{name}}Params {{name}}.Model {{name}}.Msg Model Msg Global.Model Global.Msg msg
{{camelCase}} =
    {{name}}.page
        { toModel = {{name}}Model
        , toMsg = {{name}}Msg
        }"""
        |> String.replace "{{camelCase}}" (camelCase name)
        |> String.replace "{{name}}" name


{-| camelCase "NotFound"

    "notFound"

-}
camelCase : String -> String
camelCase name =
    case String.toList name of
        first :: rest ->
            String.fromList (Char.toLower first :: rest)

        _ ->
            name


type alias TopLevelFunctionOptions =
    { name : String
    , types :
        { input : String
        , output : String
        }
    , inputs : String
    , caseExpression : CaseExpression
    }


type alias CaseExpression =
    { value : String
    , condition : String -> String
    , result : String -> String
    }


{-| topLevelFunction

    topLevelFunction
        { name = "update"
        , types =
            { input = "Msg -> Model"
            , output = "Page.Update Model Msg Global.Model Global.Msg"
            }
        , inputs = "msg_ model_"
        , caseExpression =
            { value = "( msg_, model_ )"
            , condition = \name -> String.concat [ "( ", name, "Msg msg, ", name, "Model model )" ]
            , result = \name -> String.concat [ camelCase name, ".update msg model" ]
            }
        }
        [ "Counter", "Index", "NotFound" ]

    update : Msg -> Model -> Page.Update Model Msg Global.Model Global.Msg
    update msg_ model_ =
        case ( msg_, model_ ) of
            ( CounterMsg msg, CounterModel model ) ->
                counter.update msg model

            ( IndexMsg msg, IndexModel model ) ->
                index.update msg model

            ( NotFoundMsg msg, NotFoundModel model ) ->
                notFound.update msg model

-}
topLevelFunction : TopLevelFunctionOptions -> List Item -> String
topLevelFunction options items =
    """{{name}} : {{types.input}} -> {{types.output}}
{{name}} {{inputs}} =
    case {{caseExpression.value}} of
        {{conditions}}"""
        |> String.replace "{{name}}" options.name
        |> String.replace "{{types.input}}" options.types.input
        |> String.replace "{{types.output}}" options.types.output
        |> String.replace "{{inputs}}" options.inputs
        |> String.replace "{{caseExpression.value}}" options.caseExpression.value
        |> String.replace "{{conditions}}" (conditions options.caseExpression items)


conditions : CaseExpression -> List Item -> String
conditions caseExpression items =
    items
        |> List.map Item.name
        |> List.map
            (\name ->
                """{{condition}} ->
            {{result}}"""
                    |> String.replace "{{condition}}" (caseExpression.condition name)
                    |> String.replace "{{result}}" (caseExpression.result name)
            )
        |> String.join "\n\n        "

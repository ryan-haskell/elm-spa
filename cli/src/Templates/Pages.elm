module Templates.Pages exposing (contents)

import Item exposing (Item)
import Templates.Shared as Shared


contents : String -> List Item -> List String -> String
contents ui items path =
    """module {{module_}} exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page
{{folderImports}}
import {{routeModule}} as Route
import {{ui}}
import {{layoutModule}} as Layout
{{fileImports}}


{{models}}


{{msgs}}


page =
    Page.layout
        { map = {{ui}}.map
        , view = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


{{recipes}}


{{init}}


{{update}}
{{updateLastCase}}


{{bundle}}

"""
        |> String.replace "{{module_}}" (module_ path)
        |> String.replace "{{routeModule}}" (routeModule path)
        |> String.replace "{{layoutModule}}" (layoutModule path)
        |> String.replace "{{fileImports}}" (fileImports items path)
        |> String.replace "{{folderImports}}" (folderImports items path)
        |> String.replace "{{models}}" (Shared.customTypes "Model" items)
        |> String.replace "{{msgs}}" (Shared.customTypes "Msg" items)
        |> String.replace "{{recipes}}" (recipes items)
        |> String.replace "{{init}}"
            (topLevelFunction
                { name = "init"
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
                , inputs = "msg_ model_"
                , caseExpression =
                    { value = "( msg_, model_ )"
                    , condition = \name -> String.concat [ "( ", name, "Msg msg, ", name, "Model model )" ]
                    , result = \name -> String.concat [ camelCase name, ".update msg model" ]
                    }
                }
                items
            )
        |> String.replace "{{updateLastCase}}" (updateLastCase items)
        |> String.replace "{{bundle}}"
            (topLevelFunction
                { name = "bundle"
                , inputs = "model_"
                , caseExpression =
                    { value = "model_"
                    , condition = \name -> String.concat [ name, "Model model" ]
                    , result = \name -> String.concat [ camelCase name, ".bundle model" ]
                    }
                }
                items
            )
        |> String.replace "{{ui}}" ui


module_ : List String -> String
module_ path =
    "Generated.Pages" ++ (path |> List.map ((++) ".") |> String.concat)


routeModule : List String -> String
routeModule path =
    "Generated.Route" ++ (path |> List.map ((++) ".") |> String.concat)


layoutModule : List String -> String
layoutModule path =
    "Layouts"
        ++ (if path == [] then
                ".Main"

            else
                path |> List.map ((++) ".") |> String.concat
           )


{-| fileImports

    import Pages.Counter as Counter
    import Pages.Index as Index
    import Pages.NotFound as NotFound
    import Pages.Random as Random
    import Pages.SignIn as SignIn

-}
fileImports : List Item -> List String -> String
fileImports items path =
    Item.files items
        |> List.map
            (\file ->
                String.concat
                    [ "import Pages"
                    , path |> List.map ((++) ".") |> String.concat
                    , "."
                    , file.name
                    , " as "
                    , file.name
                    ]
            )
        |> String.join "\n"


{-| folderImports

    import Generated.Pages.Settings as Settings
    import Generated.Pages.Users as Users

-}
folderImports : List Item -> List String -> String
folderImports items path =
    Item.folders items
        |> List.map
            (\folder ->
                String.concat
                    [ "import Generated.Pages"
                    , path |> List.map ((++) ".") |> String.concat
                    , "."
                    , folder.name
                    , " as "
                    , folder.name
                    ]
            )
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
    """{{camelCase}} =
        Page.recipe {{name}}.page
        { toModel = {{name}}Model
        , toMsg = {{name}}Msg
        , map = {{ui}}.map
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
        , inputs = "msg_ model_"
        , caseExpression =
            { value = "( msg_, model_ )"
            , condition = \name -> String.concat [ "( ", name, "Msg msg, ", name, "Model model )" ]
            , result = \name -> String.concat [ camelCase name, ".update msg model" ]
            }
        }
        [ "Counter", "Index", "NotFound" ]

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
    """{{name}} {{inputs}} =
    case {{caseExpression.value}} of
        {{conditions}}"""
        |> String.replace "{{name}}" options.name
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


updateLastCase : List a -> String
updateLastCase list =
    if List.length list > 1 then
        """
        _ ->
            Page.keep model_"""

    else
        ""

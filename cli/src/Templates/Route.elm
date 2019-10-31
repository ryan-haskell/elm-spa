module Templates.Route exposing (contents)

import Item exposing (Item)
import Templates.Shared as Shared


contents : List Item -> List String -> String
contents items path =
    """module {{module_}} exposing
    ( Route(..)
    , routes
    , toPath
    , {{exports}}
    )


import Application.Route as Route
{{folderImports}}


{{fileParams}}


{{folderParams}}

 
{{routeTypes}}


routes =
    [ {{routes}}
    ]


toPath route =
    case route of
        {{toPath}}

"""
        |> String.replace "{{module_}}" (module_ path)
        |> String.replace "{{exports}}" (exports items)
        |> String.replace "{{folderImports}}" (folderImports items path)
        |> String.replace "{{fileParams}}" (fileParams items)
        |> String.replace "{{folderParams}}" (folderParams items)
        |> String.replace "{{routeTypes}}"
            (Shared.specialCustomTypes
                { first = "Route"
                , second = ""
                , third = "Params"
                }
                items
            )
        |> String.replace "{{routes}}" (routes items)
        |> String.replace "{{toPath}}" (toPath items)


module_ : List String -> String
module_ path =
    "Generated.Route" ++ (path |> List.map ((++) ".") |> String.concat)


exports : List Item -> String
exports items =
    items
        |> List.map Item.name
        |> List.map (\name -> String.concat [ name, "Params" ])
        |> String.join "\n    , "


folderImports : List Item -> List String -> String
folderImports items path =
    Item.folders items
        |> List.map
            (\{ name } ->
                String.concat
                    [ "import Generated.Route"
                    , path |> List.map ((++) ".") |> String.concat
                    , "."
                    , name
                    , " as "
                    , name
                    ]
            )
        |> String.join "\n"


fileParams : List Item -> String
fileParams items =
    Item.files items
        |> List.map
            (\{ name } ->
                String.concat
                    [ "type alias "
                    , name
                    , "Params =\n    "
                    , if name == "Slug" then
                        "String"

                      else
                        "()"
                    ]
            )
        |> String.join "\n\n\n"


folderParams : List Item -> String
folderParams items =
    Item.folders items
        |> List.map
            (\{ name } ->
                String.concat
                    [ "type alias "
                    , name
                    , "Params =\n    "
                    , name
                    , ".Route"
                    ]
            )
        |> String.join "\n\n\n"


routes : List Item -> String
routes items =
    List.concat
        [ Item.files items
            |> List.map
                (\{ name } ->
                    if name == "Index" then
                        "Route.index Index"

                    else if name == "Slug" then
                        "Route.slug Slug"

                    else
                        String.concat [ "Route.path \"", pathOf name, "\" ", name ]
                )
        , Item.folders items
            |> List.map (\{ name } -> String.concat [ "Route.folder \"", pathOf name, "\" ", name, " ", name, ".routes" ])
        ]
        |> String.join "\n    , "


pathOf : String -> String
pathOf name =
    name
        |> String.toList
        |> List.map
            (\c ->
                if Char.isUpper c then
                    "-" ++ String.fromChar c

                else
                    String.fromChar c
            )
        |> (String.concat >> String.dropLeft 1 >> String.toLower)


toPath : List Item -> String
toPath items =
    List.concat
        [ Item.files items
            |> List.map
                (\{ name } ->
                    if name == "Index" then
                        "Index _ ->\n            \"/\""

                    else
                        String.concat
                            [ name
                            , " _ ->\n            \"/"
                            , pathOf name
                            , "\""
                            ]
                )
        , Item.folders items
            |> List.map
                (\{ name } ->
                    String.concat
                        [ name
                        , " route_ ->\n            \"/"
                        , pathOf name
                        , "\" ++ "
                        , name
                        , ".toPath route_"
                        ]
                )
        ]
        |> String.join "\n\n        "

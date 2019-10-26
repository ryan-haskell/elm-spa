module Templates.TopLevelRoute exposing (contents)

import Item exposing (Item)
import Templates.Shared as Shared


contents : List Item -> String
contents items =
    """module Generated.Route exposing
    ( Route(..)
    , routes
    , toPath
    , {{exports}}
    )

{-|

@docs Route
@docs routes
@docs toPath

-}

import Application.Route as Route
{{folderImports}}


{{fileParams}}


{{folderParams}}

 
{{routeTypes}}


routes : List (Route.Route Route)
routes =
    [ {{routes}}
    ]


toPath : Route -> String
toPath route =
    case route of
        {{toPath}}

"""
        |> String.replace "{{exports}}" (exports items)
        |> String.replace "{{folderImports}}" (folderImports items)
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


exports : List Item -> String
exports items =
    items
        |> List.map Item.name
        |> List.map (\name -> String.concat [ name, "Params" ])
        |> String.join "\n    , "


folderImports : List Item -> String
folderImports items =
    Item.folders items
        |> List.map (\{ name } -> String.concat [ "import Generated.Route.", name, " as ", name ])
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

                    else
                        String.concat [ "Route.path \"", path name, "\" ", name ]
                )
        , Item.folders items
            |> List.map (\{ name } -> String.concat [ "Route.folder \"", path name, "\" ", name, " ", name, ".routes" ])
        ]
        |> String.join "\n    , "


path : String -> String
path name =
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
                            , path name
                            , "\""
                            ]
                )
        , Item.folders items
            |> List.map
                (\{ name } ->
                    String.concat
                        [ name
                        , " route_ ->\n            \"/"
                        , path name
                        , "\" ++ "
                        , name
                        , ".toPath route_"
                        ]
                )
        ]
        |> String.join "\n\n        "

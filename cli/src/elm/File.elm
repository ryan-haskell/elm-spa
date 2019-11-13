module File exposing
    ( File
    , encode
    , params
    )

import Json.Encode as Json


type alias File =
    { filepath : List String
    , contents : String
    }


encode : File -> Json.Value
encode file =
    Json.object
        [ ( "filepath", Json.list Json.string file.filepath )
        , ( "contents", Json.string file.contents )
        ]



-- PARAMS TEMPLATE


params :
    { moduleName : String
    , paths : List (List String)
    }
    -> String
params options =
    """
module {{moduleName}} exposing (..)


{{paramsTypeAliases}}
    """
        |> String.replace "{{moduleName}}"
            (paramsModuleName options.moduleName)
        |> String.replace "{{paramsTypeAliases}}"
            (paramsTypeAliases options.paths)
        |> String.trim


paramsModuleName : String -> String
paramsModuleName name =
    [ "Generated", name, "Params" ]
        |> List.filter (String.isEmpty >> not)
        |> String.join "."


paramsTypeAliases : List (List String) -> String
paramsTypeAliases =
    List.map paramsTypeAlias >> String.join "\n\n\n"


paramsTypeAlias : List String -> String
paramsTypeAlias filepath =
    """
type alias {{last}} =
{{paramsRecord}}
    """
        |> String.replace "{{last}}"
            (last filepath |> Maybe.withDefault "")
        |> String.replace "{{paramsRecord}}"
            (paramsRecord filepath |> indent 1)
        |> String.trim


paramsRecord : List String -> String
paramsRecord path =
    let
        dynamicCount =
            path
                |> List.filter ((==) "Dynamic")
                |> List.length
    in
    if dynamicCount < 1 then
        "{}"

    else
        List.range 1 dynamicCount
            |> List.map String.fromInt
            |> List.map (\num -> [ "param", num, " : String" ])
            |> List.map String.concat
            |> String.join "\n, "
            |> (\str -> "{ " ++ str ++ "\n}")



-- UTILS


last : List a -> Maybe a
last list =
    List.drop (List.length list - 1) list |> List.head


indent : Int -> String -> String
indent tabs str =
    str
        |> String.split "\n"
        |> List.map (\s -> String.concat (List.repeat tabs "    " ++ [ s ]))
        |> String.join "\n"

module File exposing
    ( File
    , encode
    , params
    , route
    )

import Json.Encode as Json


type alias Filepath =
    List String


type alias GroupedFiles =
    { moduleName : String
    , paths : List Filepath
    }


type alias File =
    { filepath : Filepath
    , contents : String
    }


encode : File -> Json.Value
encode file =
    Json.object
        [ ( "filepath", Json.list Json.string file.filepath )
        , ( "contents", Json.string file.contents )
        ]



-- PARAMS


params : GroupedFiles -> File
params options =
    { filepath = filepathFor options.moduleName "Params"
    , contents = paramsContents options
    }


paramsContents : GroupedFiles -> String
paramsContents options =
    """
module {{paramModuleName}} exposing (..)


{{paramsTypeAliases}}
    """
        |> String.replace "{{paramModuleName}}"
            (paramsModuleName options.moduleName)
        |> String.replace "{{paramsTypeAliases}}"
            (paramsTypeAliases options.paths)
        |> String.trim


paramsModuleName : String -> String
paramsModuleName =
    moduleNameFor "Params"


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
    if dynamicCount > 0 then
        List.range 1 dynamicCount
            |> List.map String.fromInt
            |> List.map (\num -> [ "param", num, " : String" ])
            |> List.map String.concat
            |> String.join "\n, "
            |> (\str -> "{ " ++ str ++ "\n}")

    else
        "{}"



-- ROUTES


route : GroupedFiles -> File
route options =
    { filepath = filepathFor options.moduleName "Route"
    , contents = routeContents options
    }


routeContents : GroupedFiles -> String
routeContents options =
    """
module {{routeModuleName}} exposing
    ( Route(..)
    , toPath
    )

{{routeImports}}
    """
        |> String.replace "{{routeModuleName}}" (routeModuleName options.moduleName)
        |> String.replace "{{routeImports}}" (routeImports options.moduleName)
        |> String.trim


routeModuleName : String -> String
routeModuleName =
    moduleNameFor "Route"


routeImports moduleName =
    """
import {{paramModuleName}} as Params
{{routeFolderImports}}
    """
        |> String.replace "{{paramModuleName}}"
            (paramsModuleName moduleName)
        |> String.replace "{{routeFolderImports}}"
            (routeFolderImports moduleName [ "Docs", "Guide" ])
        |> String.trim


routeFolderImports : String -> List String -> String
routeFolderImports moduleName folderNames =
    folderNames
        |> List.map (routeFolderModuleName moduleName)
        |> List.map (String.append "import ")
        |> String.join "\n"
        |> String.trim


routeFolderModuleName : String -> String -> String
routeFolderModuleName moduleName folderName =
    "{{moduleFolder}}.{{folderName}}.Route"
        |> String.replace "{{folderName}}" folderName
        |> String.replace "{{moduleFolder}}"
            (String.join "." <| List.filter nonEmptyString ("Generated" :: String.split "." moduleName))


routeTypes =
    """
type Route
    = Top Generated.Params.Top
    | Docs Generated.Params.Docs
    | NotFound Generated.Params.NotFound
    | SignIn Generated.Params.SignIn
    | Guide Generated.Params.Guide
    | Guide_Folder Generated.Guide.Route.Route
    | Docs_Folder Generated.Docs.Route.Route
"""
        |> String.trim


routeToPath =
    """
toPath : Route -> String
toPath route =
    case route of
        Top _ ->
            "/"

        Docs _ ->
            "/docs"

        NotFound _ ->
            "/not-found"

        SignIn _ ->
            "/sign-in"

        Guide _ ->
            "/guide"

        Guide_Folder subRoute ->
            "/guide" ++ Generated.Guide.Route.toPath subRoute

        Docs_Folder subRoute ->
            "/docs" ++ Generated.Docs.Route.toPath subRoute
    """
        |> String.trim



-- UTILS


fromModuleName : String -> List String
fromModuleName =
    String.split "."
        >> List.filter (not << String.isEmpty)


last : List a -> Maybe a
last list =
    List.drop (List.length list - 1) list |> List.head


indent : Int -> String -> String
indent tabs str =
    str
        |> String.split "\n"
        |> List.map (\s -> String.concat (List.repeat tabs "    " ++ [ s ]))
        |> String.join "\n"


filepathFor : String -> String -> List String
filepathFor moduleName name =
    fromModuleName moduleName ++ [ name ]


moduleNameFor : String -> String -> String
moduleNameFor ending name =
    [ "Generated", name, ending ]
        |> List.filter (String.isEmpty >> not)
        |> String.join "."


nonEmptyString : String -> Bool
nonEmptyString =
    not << String.isEmpty

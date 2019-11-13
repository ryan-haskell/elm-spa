module File exposing
    ( Details
    , File
    , encode
    , params
    , route
    )

import Json.Encode as Json


type alias Filepath =
    List String


type alias Details =
    { moduleName : String
    , folders : List Filepath
    , files : List Filepath
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


params : Details -> File
params details =
    { filepath = filepathFor details.moduleName "Params"
    , contents = paramsContents details
    }


paramsContents : Details -> String
paramsContents details =
    """
module {{paramModuleName}} exposing (..)


{{paramsTypeAliases}}
    """
        |> String.replace "{{paramModuleName}}"
            (paramsModuleName details.moduleName)
        |> String.replace "{{paramsTypeAliases}}"
            (paramsTypeAliases details.files)
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
            (last filepath)
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


route : Details -> File
route details =
    { filepath = filepathFor details.moduleName "Route"
    , contents = routeContents details
    }


routeContents : Details -> String
routeContents details =
    """
module {{routeModuleName}} exposing
    ( Route(..)
    , toPath
    )

{{routeImports}}


{{routeTypes}}


{{routeToPath}}
    """
        |> String.replace "{{routeModuleName}}"
            (routeModuleName details.moduleName)
        |> String.replace "{{routeImports}}"
            (routeImports details)
        |> String.replace "{{routeTypes}}"
            (routeTypes details)
        |> String.replace "{{routeToPath}}"
            (routeToPath details)
        |> String.trim


routeModuleName : String -> String
routeModuleName =
    moduleNameFor "Route"


routeModuleNameFromFilepath : Filepath -> String
routeModuleNameFromFilepath =
    String.join "." >> routeModuleName


routeImports : Details -> String
routeImports details =
    """
import {{paramModuleName}} as Params
{{routeFolderImports}}
    """
        |> String.replace "{{paramModuleName}}"
            (paramsModuleName details.moduleName)
        |> String.replace "{{routeFolderImports}}"
            (routeFolderImports details.folders)
        |> String.trim


routeFolderImports : List Filepath -> String
routeFolderImports folderNames =
    folderNames
        |> List.map routeModuleNameFromFilepath
        |> List.map (String.append "import ")
        |> String.join "\n"
        |> String.trim


routeTypes details =
    """
type Route
{{routeVariants}}
    """
        |> String.replace "{{routeVariants}}" (routeVariants details)
        |> String.trim


routeVariants : Details -> String
routeVariants { folders, files } =
    List.concat
        [ List.map routeFileVariant files
        , List.map routeFolderVariant folders
        ]
        |> (\list ->
                case list of
                    [] ->
                        ""

                    head :: rest ->
                        ("= " ++ head)
                            :: rest
                            |> String.join "\n| "
                            |> indent 1
           )


routeFolderVariant : Filepath -> String
routeFolderVariant name =
    (if last name == "Dynamic" then
        "{{name}}_Folder String {{routeModuleName}}.Route"

     else
        "{{name}}_Folder {{routeModuleName}}.Route"
    )
        |> String.replace "{{name}}" (last name)
        |> String.replace "{{routeModuleName}}" (routeModuleNameFromFilepath name)


routeFileVariant : Filepath -> String
routeFileVariant name =
    if last name == "Dynamic" then
        "Dynamic String Params.Dynamic"

    else
        "{{name}} Params.{{name}}"
            |> String.replace "{{name}}" (last name)


type Item
    = StaticFile Filepath
    | DynamicFile Filepath
    | StaticFolder Filepath
    | DynamicFolder Filepath


routeCaseTemplate : Item -> String
routeCaseTemplate item =
    case item of
        StaticFile filepath ->
            """
{{name}} _ ->
    "/{{slug}}"
            """
                |> String.replace "{{name}}" (last filepath)
                |> String.replace "{{slug}}" (sluggify (last filepath))

        DynamicFile _ ->
            """
Dynamic value _ ->
    "/" ++ value
        """

        StaticFolder filepath ->
            """
{{name}}_Folder subRoute ->
    "/{{slug}}" ++ {{routeModuleName}}.toPath subRoute
        """
                |> String.replace "{{name}}" (last filepath)
                |> String.replace "{{slug}}" (sluggify (last filepath))
                |> String.replace "{{routeModuleName}}" (routeModuleNameFromFilepath filepath)

        DynamicFolder filepath ->
            """
Dynamic_Folder value subRoute ->
    "/" ++ value ++ {{routeModuleName}}.toPath subRoute
        """
                |> String.replace "{{routeModuleName}}" (routeModuleNameFromFilepath filepath)


routeToPath : Details -> String
routeToPath details =
    """
toPath : Route -> String
toPath route =
    case route of
{{cases}}
    """
        |> String.replace "{{cases}}"
            (toItems details
                |> List.map routeCaseTemplate
                |> List.map String.trim
                |> String.join "\n\n\n"
                |> indent 2
            )
        |> String.trim


toItems : Details -> List Item
toItems { folders, files } =
    let
        endsInDynamic path =
            last path == "Dynamic"

        ( dynamicFiles, staticFiles ) =
            List.partition endsInDynamic files

        ( dynamicFolders, staticFolders ) =
            List.partition endsInDynamic folders
    in
    [ List.map StaticFile staticFiles
    , List.map StaticFolder staticFolders
    , List.map DynamicFile dynamicFiles
    , List.map DynamicFolder dynamicFolders
    ]
        |> List.concat



-- UTILS


fromModuleName : String -> List String
fromModuleName =
    String.split "."
        >> List.filter (not << String.isEmpty)


last : List String -> String
last list =
    List.drop (List.length list - 1) list
        |> List.head
        |> Maybe.withDefault ""


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


sluggify : String -> String
sluggify word =
    String.toList word
        |> List.map
            (\c ->
                if Char.isUpper c then
                    [ '-', c ]

                else
                    [ c ]
            )
        |> List.concat
        |> String.fromList
        |> String.toLower
        |> String.dropLeft 1

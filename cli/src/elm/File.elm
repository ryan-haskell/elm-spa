module File exposing
    ( Details
    , File
    , encode
    , params
    , route
    , routes
    )

import Json.Encode as Json
import Set exposing (Set)


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


dynamicCount path =
    path
        |> List.filter ((==) "Dynamic")
        |> List.length


paramsRecord : List String -> String
paramsRecord path =
    if dynamicCount path > 0 then
        List.range 1 (dynamicCount path)
            |> List.map String.fromInt
            |> List.map (\num -> [ "param", num, " : String" ])
            |> List.map String.concat
            |> String.join "\n, "
            |> (\str -> "{ " ++ str ++ "\n}")

    else
        "{}"



-- ROUTE


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
        |> asImports


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



-- ROUTES


routes : List Filepath -> String
routes filepaths =
    """
module Generated.Routes exposing
    ( Route
    , parsers
    , routes
    , toPath
    )

{{routesFolderImports}}
import Url.Parser as Parser exposing ((</>), Parser, map, s, string, top)



-- ALIASES


type alias Route =
    Generated.Route.Route


toPath : Route -> String
toPath =
    Generated.Route.toPath



-- ROUTES


type alias Routes =
{{routesTypeAliases}}


routes : Routes
routes =
{{routesRecords}}
 

parsers : List (Parser (Route -> a) a)
parsers =
{{routesParserLines}}
    """
        |> String.replace "{{routesFolderImports}}" (routesFolderImports filepaths)
        |> String.replace "{{routesTypeAliases}}" (routesTypeAliases filepaths)
        |> String.replace "{{routesRecords}}" (routesRecords filepaths)
        |> String.replace "{{routesParserLines}}" (routesParserLines filepaths)
        |> String.trim


routesFolderImports : List Filepath -> String
routesFolderImports files =
    files
        |> List.map dropLast
        |> Set.fromList
        |> Set.toList
        |> List.map
            (\path ->
                [ [ "Generated" ], path, [ "Route" ] ]
                    |> List.concat
                    |> String.join "."
            )
        |> asImports


routesTypeAliases : List Filepath -> String
routesTypeAliases paths =
    paths
        |> List.sortWith shortestPathThenStatic
        |> List.map routesTypeAlias
        |> List.map String.trim
        |> asRecord
        |> indent 1


routesTypeAlias : Filepath -> String
routesTypeAlias path =
    "{{routesName}} : {{routesTypeAnnotation}}"
        |> String.replace "{{routesName}}" (routesName path)
        |> String.replace "{{routesTypeAnnotation}}" (routesTypeAnnotation path)


routesTypeAnnotation : Filepath -> String
routesTypeAnnotation path =
    case dynamicCount path of
        0 ->
            "Route"

        count ->
            List.repeat count "String"
                |> String.join " -> "
                |> (\x -> x ++ " -> Route")


routesRecords : List Filepath -> String
routesRecords paths =
    paths
        |> List.sortWith shortestPathThenStatic
        |> List.map routesRecord
        |> List.map String.trim
        |> asRecord
        |> indent 1


routesRecord : Filepath -> String
routesRecord path =
    """{{routesName}} =
{{routesRecordFunction}}
    """
        |> String.replace "{{routesName}}" (routesName path)
        |> String.replace "{{routesRecordFunction}}" (routesRecordFunction path)
        |> String.trim


routesRecordFunction : Filepath -> String
routesRecordFunction path =
    let
        inputs count =
            "\\{{params}} ->"
                |> String.replace "{{params}}"
                    (List.range 1 count
                        |> List.map String.fromInt
                        |> List.map (\num -> "param" ++ num)
                        |> String.join " "
                    )

        record count =
            "{ "
                ++ (List.range 1 count
                        |> List.map String.fromInt
                        |> List.map (\num -> "param" ++ num ++ " = param" ++ num)
                        |> String.join ", "
                   )
                ++ " }"

        everySubset path_ =
            List.length path_
                |> List.range 1
                |> List.map (\x -> List.reverse path_ |> List.drop x |> List.reverse)
                |> List.reverse
                |> List.drop 1

        swapLastTwo : String -> String
        swapLastTwo =
            String.split "."
                >> List.reverse
                >> (\list ->
                        case list of
                            [] ->
                                list

                            a :: [] ->
                                list

                            a :: b :: rest ->
                                b :: a :: rest
                   )
                >> List.reverse
                >> String.join "."

        suffix : List String -> String
        suffix path_ =
            if endsInDynamic path_ then
                " param" ++ String.fromInt (dynamicCount path_)

            else
                ""

        body =
            everySubset path
                |> List.map (routeModuleNameFromFilepath >> swapLastTwo)
                |> List.indexedMap
                    (\i value ->
                        let
                            path_ =
                                String.split "." value
                        in
                        indent i <|
                            if i < List.length path then
                                value ++ ("_Folder" ++ suffix path_ ++ " <|")

                            else
                                value ++ suffix path_
                    )
                |> (\list -> list ++ [ indent (List.length path - 1) finalPiece ])
                |> String.join "\n"

        finalPiece =
            (path
                |> (routeModuleNameFromFilepath >> swapLastTwo)
            )
                ++ suffix path
    in
    case dynamicCount path of
        0 ->
            body
                ++ " {}"
                |> indent 1

        count ->
            [ inputs count
            , indent 1 body ++ " " ++ record count
            ]
                |> String.join "\n"
                |> indent 1


routesParserLines : List Filepath -> String
routesParserLines paths =
    paths
        |> List.sortWith shortestPathThenStatic
        |> List.map routesParserLine
        |> List.map String.trim
        |> asList
        |> indent 1


shortestPathThenStatic : Filepath -> Filepath -> Order
shortestPathThenStatic a b =
    if List.length a < List.length b then
        Basics.LT

    else if List.length a > List.length b then
        Basics.GT

    else if last a == "Dynamic" then
        Basics.GT

    else if last b == "Dynamic" then
        Basics.LT

    else
        Basics.EQ


routesParserLine : Filepath -> String
routesParserLine path =
    """
map routes.{{routesName}}
    ({{routesParser}})
    """
        |> String.replace "{{routesName}}" (routesName path)
        |> String.replace "{{routesParser}}" (routesParser path)
        |> String.trim


routesName : Filepath -> String
routesName filepath =
    filepath
        |> List.map uncapitalize
        |> String.join "_"


routesParser : Filepath -> String
routesParser filepath =
    let
        parserFor piece =
            case piece of
                "Top" ->
                    "top"

                "Dynamic" ->
                    "string"

                _ ->
                    "s \"" ++ sluggify piece ++ "\""
    in
    case filepath of
        [] ->
            "UNKNOWN"

        first :: [] ->
            parserFor first

        first :: rest ->
            parserFor first ++ " </> " ++ routesParser rest



-- UTILS


asImports : List String -> String
asImports lines =
    lines
        |> List.map (String.append "import ")
        |> String.join "\n"
        |> String.trim


asRecord : List String -> String
asRecord =
    asDataStructure "{" "}"


asList : List String -> String
asList =
    asDataStructure "[" "]"


asDataStructure : String -> String -> List String -> String
asDataStructure left right items =
    case items of
        [] ->
            left ++ right

        _ ->
            left ++ " " ++ String.join "\n, " items ++ "\n" ++ right


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


uncapitalize : String -> String
uncapitalize word =
    case String.toList word of
        [] ->
            ""

        c :: rest ->
            String.fromList (Char.toLower c :: rest)


dropLast : List a -> List a
dropLast =
    List.reverse >> List.drop 1 >> List.reverse


endsInDynamic : List String -> Bool
endsInDynamic path =
    last path == "Dynamic"

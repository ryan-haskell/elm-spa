module File exposing
    ( Config
    , Details
    , File
    , encode
    , pages
    , params
    , route
    , routes
    )

import Json.Encode as Json
import Set


type alias Config =
    { ui : String
    }


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


dynamicCount : List String -> Int
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


type alias Context =
    { shouldImportParams : String -> Bool
    }


route : Context -> Details -> File
route context details =
    { filepath = filepathFor details.moduleName "Route"
    , contents = routeContents context details
    }


routeContents : Context -> Details -> String
routeContents context details =
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
            (routeImports context details)
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


routeImports : Context -> Details -> String
routeImports context details =
    """
{{paramImport}}
{{routeFolderImports}}
    """
        |> String.replace "{{paramImport}}"
            (paramImport context details)
        |> String.replace "{{routeFolderImports}}"
            (routeFolderImports details.folders)
        |> String.trim


paramImport : Context -> Details -> String
paramImport context details =
    if context.shouldImportParams details.moduleName then
        paramsModuleName details.moduleName
            |> (\str -> "import " ++ str ++ " as Params")

    else
        ""


routeFolderImports : List Filepath -> String
routeFolderImports folderNames =
    folderNames
        |> List.map routeModuleNameFromFilepath
        |> asImports


routeTypes : Details -> String
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


staticRouteCase : String -> String
staticRouteCase word =
    case word of
        "Top" ->
            """
Top _ ->
    "/"
            """

        last_ ->
            """
{{name}} _ ->
    "/{{slug}}"
            """
                |> String.replace "{{name}}" last_
                |> String.replace "{{slug}}" (sluggify last_)


routeCaseTemplate : Item -> String
routeCaseTemplate item =
    case item of
        StaticFile filepath ->
            staticRouteCase (last filepath)

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



-- PAGES


pages : Context -> Details -> File
pages context details =
    { filepath = filepathFor details.moduleName "Pages"
    , contents = pagesContents context details
    }


pagesContents : Context -> Details -> String
pagesContents context details =
    """
module {{pagesModuleName}} exposing
    ( Model
    , Msg
    , page
    , path
    )

import Spa.Page
import Spa.Path exposing (Path, static, dynamic)
import {{layoutModuleName}} as Layout
import Utils.Spa as Spa
{{paramImport}}
import {{routeModuleName}} as Route exposing (Route)
{{pagesPageImports}}
{{pagesFolderRouteImports}}
{{pagesFolderPagesImports}}


{{pagesModelTypes}}


{{pagesMsgTypes}}


page : Spa.Page Route Model Msg layoutModel layoutMsg appMsg
page =
    Spa.layout
        { path = path
        , view = Layout.view
        , recipe =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


path : Path
path =
    {{pagesLayoutPath}}


-- RECIPES


type alias Recipe flags model msg appMsg =
    Spa.Recipe flags model msg Model Msg appMsg


type alias Recipes msg =
{{pagesRecipesTypeAliases}}


recipes : Recipes msg
recipes =
{{pagesRecipesFunctions}}



-- INIT


init : Route -> Spa.Init Model Msg
init route_ =
{{pagesInitFunction}}



-- UPDATE


update : Msg -> Model -> Spa.Update Model Msg
update bigMsg bigModel =
{{pagesUpdateFunction}}
{{defaultUpdateCase}}


-- BUNDLE


bundle : Model -> Spa.Bundle Msg msg
bundle bigModel =
{{pagesBundleFunction}}
    """
        |> String.replace "{{pagesModuleName}}" (pagesModuleName details.moduleName)
        |> String.replace "{{layoutModuleName}}" (pagesLayoutModuleName details.moduleName)
        |> String.replace "{{paramImport}}" (paramImport context details)
        |> String.replace "{{routeModuleName}}" (routeModuleName details.moduleName)
        |> String.replace "{{pagesPageImports}}" (pagesPageImports details.files)
        |> String.replace "{{pagesFolderRouteImports}}" (pagesFolderImports "Route" details.folders)
        |> String.replace "{{pagesFolderPagesImports}}" (pagesFolderImports "Pages" details.folders)
        |> String.replace "{{pagesModelTypes}}" (pagesCustomTypes "Model" details)
        |> String.replace "{{pagesMsgTypes}}" (pagesCustomTypes "Msg" details)
        |> String.replace "{{pagesLayoutPath}}" (pagesLayoutPath details)
        |> String.replace "{{pagesRecipesTypeAliases}}" (pagesRecipesTypeAliases details)
        |> String.replace "{{pagesRecipesFunctions}}" (pagesRecipesFunctions details)
        |> String.replace "{{pagesInitFunction}}" (pagesInitFunction details)
        |> String.replace "{{pagesUpdateFunction}}" (pagesUpdateFunction details)
        |> String.replace "{{pagesBundleFunction}}" (pagesBundleFunction details)
        |> String.replace "{{defaultUpdateCase}}"
            (if List.length (details.files ++ details.folders) < 2 then
                ""

             else
                "_ ->\n    Spa.Page.keep bigModel" |> indent 2
            )
        |> String.trim


pagesLayoutModuleName : String -> String
pagesLayoutModuleName str =
    case str of
        "" ->
            "Layout"

        _ ->
            "Layouts." ++ str


pagesModuleName : String -> String
pagesModuleName =
    moduleNameFor "Pages"


pagesPageImports : List Filepath -> String
pagesPageImports files =
    files
        |> List.map pagesPageModule
        |> asImports


pagesPageModule : Filepath -> String
pagesPageModule path =
    path
        |> String.join "."
        |> String.append "Pages."


pagesFolderImports : String -> List Filepath -> String
pagesFolderImports suffix folders =
    folders
        |> List.map (String.join "." >> moduleNameFor suffix)
        |> asImports


pagesLayoutPath : Details -> String
pagesLayoutPath { moduleName } =
    String.split "." moduleName
        |> List.map
            (\piece ->
                case piece of
                    "Dynamic" ->
                        "dynamic"

                    _ ->
                        "static \"" ++ sluggify piece ++ "\""
            )
        |> (\pieces ->
                if List.isEmpty pieces || pieces == [ "static \"\"" ] then
                    "[]"

                else
                    "[ " ++ String.join ", " pieces ++ " ]"
           )


pagesCustomTypes : String -> Details -> String
pagesCustomTypes type_ { files, folders } =
    let
        toFileTuple : Filepath -> ( String, String )
        toFileTuple path =
            let
                name =
                    last path
            in
            ( name ++ type_
            , pagesPageModule path ++ "." ++ type_
            )

        toFolderTuple : Filepath -> ( String, String )
        toFolderTuple path =
            let
                name =
                    last path
            in
            ( name ++ "_Folder_" ++ type_
            , pagesModuleName (String.join "." path) ++ "." ++ type_
            )
    in
    List.concat
        [ List.map toFileTuple files
        , List.map toFolderTuple folders
        ]
        |> asCustomType type_


asCustomType : String -> List ( String, String ) -> String
asCustomType name items =
    case items of
        [] ->
            ""

        _ ->
            items
                |> List.map (\( a, b ) -> a ++ " " ++ b)
                |> String.join "\n| "
                |> (\str ->
                        [ "type " ++ name ++ "\n"
                        , indent 1 ("= " ++ str)
                        ]
                   )
                |> String.concat


pagesRecipesTypeAliases : Details -> String
pagesRecipesTypeAliases { files, folders } =
    let
        toFileAlias : Filepath -> String
        toFileAlias path =
            "{{uncapitalizedName}} : Recipe Params.{{name}} {{pagesPageModule}}.Model {{pagesPageModule}}.Msg msg"
                |> String.replace "{{uncapitalizedName}}" (uncapitalize (last path))
                |> String.replace "{{name}}" (last path)
                |> String.replace "{{pagesPageModule}}" (pagesPageModule path)

        toFolderAlias : Filepath -> String
        toFolderAlias path =
            "{{uncapitalizedName}}_folder : Recipe {{routeModuleName}}.Route {{pagesModuleName}}.Model {{pagesModuleName}}.Msg msg"
                |> String.replace "{{uncapitalizedName}}" (uncapitalize (last path))
                |> String.replace "{{routeModuleName}}" (String.join "." path |> routeModuleName)
                |> String.replace "{{pagesModuleName}}" (String.join "." path |> pagesModuleName)
    in
    [ List.map toFileAlias files
    , List.map toFolderAlias folders
    ]
        |> List.concat
        |> asRecord
        |> indent 1


pagesRecipesFunctions : Details -> String
pagesRecipesFunctions { files, folders } =
    let
        fileRecipe : Filepath -> String
        fileRecipe path =
            [ "page = " ++ pagesPageModule path ++ ".page"
            , "toModel = " ++ last path ++ "Model"
            , "toMsg = " ++ last path ++ "Msg"
            ]
                |> asRecord
                |> String.trim
                |> indent 2

        toFileFunction : Filepath -> String
        toFileFunction path =
            """
{{uncapitalizedName}} =
    Spa.recipe
{{function}}
            """
                |> String.replace "{{uncapitalizedName}}" (uncapitalize (last path))
                |> String.replace "{{function}}" (fileRecipe path)
                |> String.trim

        folderRecipe : Filepath -> String
        folderRecipe path =
            [ "page = " ++ (String.join "." path |> pagesModuleName) ++ ".page"
            , "toModel = " ++ last path ++ "_Folder_Model"
            , "toMsg = " ++ last path ++ "_Folder_Msg"
            ]
                |> asRecord
                |> String.trim
                |> indent 2

        toFolderFunction : Filepath -> String
        toFolderFunction path =
            """
{{uncapitalizedName}}_folder =
    Spa.recipe
{{function}}
            """
                |> String.replace "{{uncapitalizedName}}" (uncapitalize (last path))
                |> String.replace "{{function}}" (folderRecipe path)
                |> String.trim
    in
    [ List.map toFileFunction files
    , List.map toFolderFunction folders
    ]
        |> List.concat
        |> asRecord
        |> indent 1


pagesInitFunction : Details -> String
pagesInitFunction details =
    toItems details
        |> List.map pagesToInit
        |> asCaseExpression "route_"
        |> indent 1


pagesToInit : Item -> String
pagesToInit item =
    case item of
        StaticFile path ->
            "Route.{{name}} params ->\n    recipes.{{uncapitalized}}.init params"
                |> String.replace "{{name}}" (last path)
                |> String.replace "{{uncapitalized}}" (uncapitalize (last path))

        DynamicFile _ ->
            "Route.Dynamic _ params ->\n    recipes.dynamic.init params"

        StaticFolder path ->
            "Route.{{name}}_Folder route ->\n    recipes.{{uncapitalized}}_folder.init route"
                |> String.replace "{{name}}" (last path)
                |> String.replace "{{uncapitalized}}" (uncapitalize (last path))

        DynamicFolder _ ->
            "Route.Dynamic_Folder _ route ->\n    recipes.dynamic_folder.init route"


pagesUpdateFunction : Details -> String
pagesUpdateFunction details =
    toItems details
        |> List.map pagesToUpdate
        |> asCaseExpression "( bigMsg, bigModel )"
        |> indent 1


pagesToUpdate : Item -> String
pagesToUpdate item =
    case item of
        StaticFile path ->
            "( {{name}}Msg msg, {{name}}Model model ) ->\n    recipes.{{uncapitalized}}.update msg model"
                |> String.replace "{{name}}" (last path)
                |> String.replace "{{uncapitalized}}" (uncapitalize (last path))

        DynamicFile _ ->
            "( DynamicMsg msg, DynamicModel model ) ->\n    recipes.dynamic.update msg model"

        StaticFolder path ->
            "( {{name}}_Folder_Msg msg, {{name}}_Folder_Model model ) ->\n    recipes.{{uncapitalized}}_folder.update msg model"
                |> String.replace "{{name}}" (last path)
                |> String.replace "{{uncapitalized}}" (uncapitalize (last path))

        DynamicFolder _ ->
            "( Dynamic_Folder_Msg msg, Dynamic_Folder_Model model ) ->\n    recipes.dynamic_folder.update msg model"


pagesBundleFunction : Details -> String
pagesBundleFunction details =
    toItems details
        |> List.map pagesToBundle
        |> asCaseExpression "bigModel"
        |> indent 1


pagesToBundle : Item -> String
pagesToBundle item =
    case item of
        StaticFile path ->
            "{{name}}Model model ->\n    recipes.{{uncapitalized}}.bundle model"
                |> String.replace "{{name}}" (last path)
                |> String.replace "{{uncapitalized}}" (uncapitalize (last path))

        DynamicFile _ ->
            "DynamicModel model ->\n    recipes.dynamic.bundle model"

        StaticFolder path ->
            "{{name}}_Folder_Model model ->\n    recipes.{{uncapitalized}}_folder.bundle model"
                |> String.replace "{{name}}" (last path)
                |> String.replace "{{uncapitalized}}" (uncapitalize (last path))

        DynamicFolder _ ->
            "Dynamic_Folder_Model model ->\n    recipes.dynamic_folder.bundle model"



-- ROUTES


routes :
    { paths : List Filepath
    , pathsWithFiles : List Filepath
    }
    -> String
routes { paths, pathsWithFiles } =
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
        |> String.replace "{{routesFolderImports}}" (routesFolderImports paths)
        |> String.replace "{{routesTypeAliases}}" (routesTypeAliases pathsWithFiles)
        |> String.replace "{{routesRecords}}" (routesRecords pathsWithFiles)
        |> String.replace "{{routesParserLines}}" (routesParserLines pathsWithFiles)
        |> String.trim


routesFolderImports : List Filepath -> String
routesFolderImports paths =
    paths
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
        inputs : Int -> String
        inputs count =
            "\\{{params}} ->"
                |> String.replace "{{params}}"
                    (List.range 1 count
                        |> List.map String.fromInt
                        |> List.map (\num -> "param" ++ num)
                        |> String.join " "
                    )

        record : Int -> String
        record count =
            "{ "
                ++ (List.range 1 count
                        |> List.map String.fromInt
                        |> List.map (\num -> "param" ++ num ++ " = param" ++ num)
                        |> String.join ", "
                   )
                ++ " }"

        everySubset : List a -> List (List a)
        everySubset path_ =
            List.length path_
                |> List.range 1
                |> List.map (\x -> List.reverse path_ |> List.drop x |> List.reverse)
                |> List.reverse
                |> List.drop 1

        swapLastTwo : List a -> List a
        swapLastTwo =
            List.reverse
                >> (\list ->
                        case list of
                            [] ->
                                list

                            _ :: [] ->
                                list

                            a :: b :: rest ->
                                b :: a :: rest
                   )
                >> List.reverse

        suffix : List String -> String
        suffix path_ =
            if endsInDynamic path_ then
                " param" ++ String.fromInt (dynamicCount path_)

            else
                ""

        toRouteModule : List String -> String
        toRouteModule =
            routeModuleNameFromFilepath
                >> String.split "."
                >> swapLastTwo
                >> String.join "."

        body : String
        body =
            everySubset path
                |> List.map toRouteModule
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
            toRouteModule path ++ suffix path
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


asCaseExpression : String -> List String -> String
asCaseExpression var cases =
    if List.isEmpty cases then
        ""

    else
        cases
            |> String.join "\n\n"
            |> indent 1
            |> (++) ("case " ++ var ++ " of\n")


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

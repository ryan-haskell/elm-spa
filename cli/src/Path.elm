module Path exposing
    ( Path
    , fromFilepath
    , fromModuleName
    , hasParams
    , optionalParams
    , toFilepath
    , toFlags
    , toList
    , toModulePath
    , toParamInputs
    , toParamList
    , toParser
    , toTypeName
    , toVariableName
    )

import Utils.Generate as Utils


type Path
    = Internals (List String)


fromFilepath : String -> Path
fromFilepath filepath =
    filepath
        |> String.replace ".elm" ""
        |> String.split "/"
        |> List.filter ((/=) "")
        |> Internals


fromModuleName : String -> Path
fromModuleName name =
    name
        |> String.split "."
        |> Internals


toFilepath : Path -> String
toFilepath (Internals list) =
    String.join "/" list ++ ".elm"


toList : Path -> List String
toList (Internals list) =
    list


toModulePath : Path -> String
toModulePath =
    join "."


toTypeName : Path -> String
toTypeName =
    join "_"


toVariableName : Path -> String
toVariableName (Internals list) =
    let
        lowercaseFirstLetter : String -> String
        lowercaseFirstLetter str =
            String.left 1 (String.toLower str) ++ String.dropLeft 1 str
    in
    list |> List.map lowercaseFirstLetter |> String.join "_"


optionalParams : Path -> String
optionalParams =
    toSingleLineParamRecord
        Utils.singleLineRecordType
        (\num -> ( "param" ++ String.fromInt num, "String" ))


toFlags : Path -> String
toFlags path =
    let
        params =
            optionalParams path
    in
    if params == "" then
        "()"

    else
        String.dropLeft 1 params


dynamicCount : Path -> Int
dynamicCount (Internals list) =
    list
        |> List.filter ((==) "Dynamic")
        |> List.length


toParser : Path -> String
toParser (Internals list) =
    let
        count : Int
        count =
            dynamicCount (Internals list)

        toUrlSegment : String -> String
        toUrlSegment piece =
            if piece == "Dynamic" then
                "Parser.string"

            else
                "Parser.s \"" ++ sluggify piece ++ "\""

        toUrlParser : List String -> String
        toUrlParser list_ =
            "("
                ++ (list_ |> stripEndingTop |> List.map toUrlSegment |> String.join " </> ")
                ++ ")"

        toStaticParser : List String -> String
        toStaticParser list_ =
            "Parser.map "
                ++ toTypeName (Internals list_)
                ++ " "
                ++ toUrlParser list_

        toParamMap : Path -> String
        toParamMap =
            toSingleLineParamRecord
                Utils.singleLineRecordValue
                (\num -> ( "param" ++ String.fromInt num, "param" ++ String.fromInt num ))

        dynamicParamsFn : List String -> String
        dynamicParamsFn list_ =
            "\\" ++ (List.range 1 count |> List.map (\num -> "param" ++ String.fromInt num) |> String.join " ") ++ " ->" ++ toParamMap (Internals list_)

        toDynamicParser : List String -> String
        toDynamicParser list_ =
            String.join "\n"
                [ toUrlParser list_
                , "  |> Parser.map (" ++ dynamicParamsFn list_ ++ ")"
                , "  |> Parser.map " ++ toTypeName (Internals list_)
                ]
    in
    case list of
        [ "Top" ] ->
            "Parser.map Top Parser.top"

        _ ->
            if count > 0 then
                toDynamicParser list

            else
                toStaticParser list


stripEndingTop : List String -> List String
stripEndingTop list_ =
    List.reverse list_
        |> (\l ->
                if List.head l == Just "Top" then
                    List.drop 1 l

                else
                    l
           )
        |> List.reverse


sluggify : String -> String
sluggify =
    String.toList
        >> List.map
            (\char ->
                if Char.isUpper char then
                    String.fromList [ ' ', char ]

                else
                    String.fromList [ char ]
            )
        >> String.concat
        >> String.trim
        >> String.replace " " "-"
        >> String.toLower



-- { param1, param2 }


toParamInputs : Path -> String
toParamInputs path =
    let
        count =
            dynamicCount path
    in
    if count == 0 then
        ""

    else
        " { " ++ (List.range 1 count |> List.map (\num -> "param" ++ String.fromInt num) |> String.join ", ") ++ " }"



-- [ "authors", param1, "posts", param2 ]


toParamList : Path -> String
toParamList (Internals list) =
    let
        helper : String -> ( List String, Int ) -> ( List String, Int )
        helper piece ( names, num ) =
            if piece == "Dynamic" then
                ( names ++ [ "param" ++ String.fromInt num ]
                , num + 1
                )

            else
                ( names ++ [ "\"" ++ sluggify piece ++ "\"" ]
                , num
                )
    in
    list
        |> stripEndingTop
        |> List.foldl helper ( [], 1 )
        |> Tuple.first
        |> (\items ->
                if List.length items == 0 then
                    "[]"

                else
                    "[ " ++ String.join ", " items ++ " ]"
           )


hasParams : Path -> Bool
hasParams path =
    dynamicCount path > 0



-- HELPERS


join : String -> Path -> String
join separator (Internals list) =
    String.join separator list


toSingleLineParamRecord :
    (List ( String, String ) -> String)
    -> (Int -> ( String, String ))
    -> Path
    -> String
toSingleLineParamRecord toRecord toItem path =
    let
        count =
            dynamicCount path
    in
    if count == 0 then
        ""

    else
        List.range 1 count
            |> List.map toItem
            |> toRecord
            |> String.append " "

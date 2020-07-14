module Path exposing
    ( Path
    , fromFilepath
    , fromModuleName
    , hasParams
    , optionalParams
    , routingOrder
    , toFilepath
    , toList
    , toModulePath
    , toParamInputs
    , toParamList
    , toParams
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
    join "__"


toVariableName : Path -> String
toVariableName (Internals list) =
    list
        |> List.map
            (\piece ->
                case getDynamicParameter piece of
                    Just ( left, right ) ->
                        lowercaseFirstLetter left ++ "_" ++ lowercaseFirstLetter right

                    Nothing ->
                        lowercaseFirstLetter piece
            )
        |> String.join "__"


optionalParams : Path -> String
optionalParams =
    toSingleLineParamRecord
        Utils.singleLineRecordType
        (\( left, right ) -> ( lowercaseFirstLetter left, right ))


toParams : Path -> String
toParams path =
    let
        params =
            optionalParams path
    in
    if params == "" then
        "()"

    else
        String.dropLeft 1 params


isDynamic : String -> Bool
isDynamic =
    String.contains "_"


dynamicCount : Path -> Int
dynamicCount (Internals list) =
    list
        |> List.filter isDynamic
        |> List.length


toParser : Path -> String
toParser (Internals list) =
    let
        count : Int
        count =
            dynamicCount (Internals list)

        toUrlSegment : String -> String
        toUrlSegment piece =
            case getDynamicParameter piece of
                Just ( _, right ) ->
                    "Parser." ++ String.toLower right

                Nothing ->
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
                (\( left, _ ) -> ( lowercaseFirstLetter left, lowercaseFirstLetter left ))

        dynamicParamsFn : List String -> String
        dynamicParamsFn list_ =
            "\\"
                ++ (List.filterMap getDynamicParameter list_
                        |> List.map (\( left, _ ) -> lowercaseFirstLetter left)
                        |> String.join " "
                   )
                ++ " ->"
                ++ toParamMap (Internals list_)

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
        " { "
            ++ (List.filterMap getDynamicParameter (toList path)
                    |> List.map (\( left, _ ) -> lowercaseFirstLetter left)
                    |> String.join ", "
               )
            ++ " }"



-- [ "authors", param1, "posts", param2 ]


lowercaseFirstLetter : String -> String
lowercaseFirstLetter str =
    case String.toList str of
        first :: rest ->
            String.fromList (Char.toLower first :: rest)

        [] ->
            str


toParamList : Path -> String
toParamList (Internals list) =
    let
        helper : String -> List String -> List String
        helper piece names =
            case getDynamicParameter piece of
                Just ( left, right ) ->
                    if right == "Int" then
                        names ++ [ "String.fromInt " ++ lowercaseFirstLetter left ]

                    else
                        names ++ [ lowercaseFirstLetter left ]

                Nothing ->
                    names ++ [ "\"" ++ sluggify piece ++ "\"" ]
    in
    list
        |> stripEndingTop
        |> List.foldl helper []
        |> (\items ->
                if List.length items == 0 then
                    "[]"

                else
                    "[ " ++ String.join ", " items ++ " ]"
           )


hasParams : Path -> Bool
hasParams path =
    dynamicCount path > 0


last : List a -> Maybe a
last list =
    list
        |> List.reverse
        |> List.head


routingOrder : Path -> Path -> Order
routingOrder (Internals list1) (Internals list2) =
    let
        endsInTop =
            last
                >> (==) (Just "Top")

        endsInDynamic =
            last
                >> Maybe.map isDynamic
                >> Maybe.withDefault False
    in
    if List.length list1 < List.length list2 then
        LT

    else if List.length list1 > List.length list2 then
        GT

    else if endsInTop list1 && not (endsInTop list2) then
        LT

    else if not (endsInTop list1) && endsInTop list2 then
        GT

    else if not (endsInDynamic list1) && endsInDynamic list2 then
        LT

    else if endsInDynamic list1 && not (endsInDynamic list2) then
        GT

    else
        EQ



-- HELPERS


join : String -> Path -> String
join separator (Internals list) =
    String.join separator list


getDynamicParameter : String -> Maybe ( String, String )
getDynamicParameter str =
    case String.split "_" str of
        [ left, right ] ->
            Just ( left, right )

        _ ->
            Nothing


toSingleLineParamRecord :
    (List ( String, String ) -> String)
    -> (( String, String ) -> ( String, String ))
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
        path
            |> toList
            |> List.filterMap getDynamicParameter
            |> List.map toItem
            |> toRecord
            |> String.append " "

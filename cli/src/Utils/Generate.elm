module Utils.Generate exposing
    ( caseExpression
    , customType
    , function
    , import_
    , indent
    , list
    , recordType
    , recordValue
    , singleLineRecordType
    , singleLineRecordValue
    , tuple
    )


indent : Int -> String -> String
indent count string =
    String.lines string
        |> List.map (String.append ("    " |> List.repeat count |> String.concat))
        |> String.join "\n"


customType :
    { name : String
    , variants : List String
    }
    -> String
customType options =
    case options.variants of
        [] ->
            ""

        first :: [] ->
            "type " ++ options.name ++ " = " ++ first

        first :: rest ->
            multilineIndentedThing
                { header = "type " ++ options.name
                , items = { first = first, rest = rest }
                , prefixes = { first = "= ", rest = "| " }
                , suffix = []
                }


module_ :
    { name : String
    , exposing_ : List String
    }
    -> String
module_ options =
    case options.exposing_ of
        [] ->
            "module " ++ options.name

        first :: [] ->
            "module " ++ options.name ++ " exposing " ++ "(" ++ first ++ ")"

        first :: rest ->
            multilineIndentedThing
                { header = "module " ++ options.name
                , items = { first = first, rest = rest }
                , prefixes = { first = "( ", rest = ", " }
                , suffix = [ ")" ]
                }


singleLineRecordType : List ( String, String ) -> String
singleLineRecordType =
    singleLineRecord " : "


singleLineRecordValue : List ( String, String ) -> String
singleLineRecordValue =
    singleLineRecord " = "


recordType : List ( String, String ) -> String
recordType =
    record (\( key, value ) -> key ++ " : " ++ value)


recordValue : List ( String, String ) -> String
recordValue =
    record (\( key, value ) -> key ++ " = " ++ value)


list : List String -> String
list values =
    case values of
        [] ->
            "[]"

        first :: [] ->
            "[ " ++ first ++ " ]"

        first :: rest ->
            multilineThing
                { items = { first = first, rest = rest }
                , prefixes = { first = "[ ", rest = ", " }
                , suffix = [ "]" ]
                }


tuple : List String -> String
tuple values =
    case values of
        [] ->
            "()"

        first :: [] ->
            "( " ++ first ++ " )"

        first :: rest ->
            multilineThing
                { items = { first = first, rest = rest }
                , prefixes = { first = "( ", rest = ", " }
                , suffix = [ ")" ]
                }


import_ :
    { name : String
    , alias : Maybe String
    , exposing_ : List String
    }
    -> String
import_ options =
    case ( options.alias, options.exposing_ ) of
        ( Nothing, [] ) ->
            "import " ++ options.name

        ( Just alias_, [] ) ->
            "import " ++ options.name ++ " as " ++ alias_

        ( Nothing, _ ) ->
            "import " ++ options.name ++ " exposing (" ++ String.join ", " options.exposing_ ++ ")"

        ( Just alias_, _ ) ->
            "import " ++ options.name ++ " as " ++ alias_ ++ " exposing (" ++ String.join ", " options.exposing_ ++ ")"


function :
    { name : String
    , inputs : List String
    , annotation : List String
    , body : String
    }
    -> String
function options =
    case options.annotation of
        [] ->
            ""

        _ ->
            String.join "\n"
                [ options.name ++ " : " ++ String.join " -> " options.annotation
                , options.name ++ " " ++ List.foldl (\arg str -> str ++ arg ++ " ") "" options.inputs ++ "="
                , options.body |> indent 1
                ]


caseExpression :
    { variable : String
    , cases : List ( String, String )
    }
    -> String
caseExpression options =
    let
        toBranch : ( String, String ) -> String
        toBranch ( value, result ) =
            String.join "\n"
                [ value ++ " ->"
                , indent 1 result
                ]
    in
    case options.cases of
        [] ->
            ""

        _ ->
            [ "case " ++ options.variable ++ " of"
            , options.cases
                |> List.map toBranch
                |> String.join "\n\n"
                |> indent 1
            ]
                |> String.join "\n"



-- HELPERS


multilineIndentedThing :
    { header : String
    , items : { first : String, rest : List String }
    , prefixes : { first : String, rest : String }
    , suffix : List String
    }
    -> String
multilineIndentedThing options =
    String.join "\n"
        [ options.header
        , multilineThing options |> indent 1
        ]


multilineThing :
    { options
        | items : { first : String, rest : List String }
        , prefixes : { first : String, rest : String }
        , suffix : List String
    }
    -> String
multilineThing { items, prefixes, suffix } =
    [ [ prefixes.first ++ items.first ]
    , List.map (String.append prefixes.rest) items.rest
    , suffix
    ]
        |> List.concat
        |> String.join "\n"


record :
    (( String, String ) -> String)
    -> List ( String, String )
    -> String
record fromTuple properties =
    case properties of
        [] ->
            "{}"

        first :: [] ->
            "{ " ++ fromTuple first ++ " }"

        first :: rest ->
            multilineThing
                { items = { first = fromTuple first, rest = List.map fromTuple rest }
                , prefixes = { first = "{ ", rest = ", " }
                , suffix = [ "}" ]
                }


singleLineRecord : String -> List ( String, String ) -> String
singleLineRecord separator properties =
    case properties of
        [] ->
            "{}"

        _ ->
            "{ "
                ++ (properties
                        |> List.map (\( k, v ) -> k ++ separator ++ v)
                        |> String.join ", "
                   )
                ++ " }"

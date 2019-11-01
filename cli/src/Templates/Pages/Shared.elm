module Templates.Pages.Shared exposing
    ( moduleName
    , routeParam
    )


moduleName : List String -> String
moduleName =
    String.join "."


routeParam : List String -> String
routeParam =
    List.reverse
        >> List.head
        >> Maybe.map ((==) "Slug")
        >> Maybe.withDefault False
        >> (\isSlug ->
                if isSlug then
                    "String"

                else
                    "()"
           )

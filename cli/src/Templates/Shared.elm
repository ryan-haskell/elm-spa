module Templates.Shared exposing (customTypes, specialCustomTypes)

import Item exposing (Item)


{-| specialCustomTypes { first = "Foo", second = "Bar", third = ".Baz" }

    type Foo
        = CounterBar Counter.Baz
        | IndexBar Index.Baz
        | NotFoundBar NotFound.Baz
        | RandomBar Random.Baz
        | SignInBar SignIn.Baz
        | SettingsBar Settings.Baz
        | UsersBar Users.Baz

-}
specialCustomTypes :
    { first : String, second : String, third : String }
    -> List Item
    -> String
specialCustomTypes { first, second, third } items =
    items
        |> List.map Item.name
        |> List.map (\name -> String.concat [ name, second, " ", name, third ])
        |> (\lines ->
                String.concat
                    [ "type "
                    , first
                    , "\n    = "
                    , String.join "\n    | " lines
                    ]
           )


customTypes : String -> List Item -> String
customTypes str =
    specialCustomTypes
        { first = str
        , second = str
        , third = "." ++ str
        }

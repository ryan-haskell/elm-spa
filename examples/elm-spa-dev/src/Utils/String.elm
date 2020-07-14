module Utils.String exposing (sluggify)


sluggify : String -> String
sluggify words =
    words
        |> String.replace " " "-"
        |> String.toLower

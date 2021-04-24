module Utils.String exposing (capitalizeFirstLetter)


capitalizeFirstLetter : String -> String
capitalizeFirstLetter str =
    String.toUpper (String.left 1 str) ++ String.dropLeft 1 str

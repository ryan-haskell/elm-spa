module Data.User exposing (User, fullname)


type alias User =
    { avatar : String
    , name :
        { first : String
        , last : String
        }
    , email : String
    }


fullname : User -> String
fullname { name } =
    name.first ++ " " ++ name.last

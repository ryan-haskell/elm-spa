module Data.User exposing (User, decoder)

import Json.Decode as D exposing (Decoder)


type alias User =
    { username : String
    }


decoder : Decoder User
decoder =
    D.map User
        (D.field "username" D.string)

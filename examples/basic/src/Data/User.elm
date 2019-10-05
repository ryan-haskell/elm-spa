module Data.User exposing (User, signIn, username)

import Utils.Cmd


type User
    = User String


username : User -> String
username (User username_) =
    username_


signIn :
    { username : String
    , password : String
    , msg : Result String User -> msg
    }
    -> Cmd msg
signIn options =
    (Utils.Cmd.toCmd << options.msg) <|
        case ( options.username, options.password ) of
            ( _, "password" ) ->
                Ok (User options.username)

            _ ->
                Err "Sign in failed."

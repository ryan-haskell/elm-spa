module Api.Users exposing (signIn)

import Data.User as User exposing (User)
import Http
import Json.Encode as Json


signIn :
    { username : String
    , password : String
    , msg : Result Http.Error User -> msg
    }
    -> Cmd msg
signIn { username, password, msg } =
    Http.post
        { url = "/api/users/sign-in"
        , body =
            Http.jsonBody <|
                Json.object
                    [ ( "username", Json.string username )
                    , ( "password", Json.string password )
                    ]
        , expect = Http.expectJson msg User.decoder
        }

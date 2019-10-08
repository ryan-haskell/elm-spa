module Global exposing
    ( Model
    , Msg(..)
    )

import Data.User exposing (User)


type alias Model =
    { user : Maybe User
    }


type Msg
    = SignIn (Result String User)
    | SignOut

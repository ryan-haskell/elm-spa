module Data.SignInForm exposing
    ( Field(..)
    , SignInForm
    , empty
    , updateEmail
    , updatePassword
    )


type alias SignInForm =
    { email : String
    , password : String
    }


type Field
    = Email
    | Password


empty : SignInForm
empty =
    { email = ""
    , password = ""
    }


updateEmail : String -> SignInForm -> SignInForm
updateEmail email form =
    { form | email = email }


updatePassword : String -> SignInForm -> SignInForm
updatePassword password form =
    { form | password = password }

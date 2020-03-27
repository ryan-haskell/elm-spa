module Data.Modal exposing
    ( Modal(..)
    , signInForm
    , updateSignInForm
    )

import Data.SignInForm exposing (SignInForm)


type Modal
    = SignInModal SignInForm


signInForm : Modal -> Maybe SignInForm
signInForm modal =
    case modal of
        SignInModal form ->
            Just form


updateSignInForm :
    (SignInForm -> SignInForm)
    -> Modal
    -> Modal
updateSignInForm fn modal =
    case modal of
        SignInModal form ->
            SignInModal (fn form)

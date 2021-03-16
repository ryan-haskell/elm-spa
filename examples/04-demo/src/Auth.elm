module Auth exposing
    ( User
    , beforeProtectedInit
    )

{-|

@docs User
@docs beforeProtectedInit

-}

import ElmSpa.Internals.Page as ElmSpa
import Gen.Route exposing (Route)
import Request exposing (Request)
import Shared


type alias User =
    Shared.User


beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit shared req =
    let
        _ =
            Debug.log "user" shared.user
    in
    case shared.user of
        Just user ->
            ElmSpa.Provide user

        Nothing ->
            ElmSpa.RedirectTo Gen.Route.SignIn

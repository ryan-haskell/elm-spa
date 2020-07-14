module Api.Data exposing
    ( Data(..)
    , fromHttpResult
    , isResolved
    , isUnresolved
    , toMaybe
    , view
    )

import Http


type Data value
    = NotAsked
    | Loading
    | Success value
    | Failure String


toMaybe : Data value -> Maybe value
toMaybe data =
    case data of
        Success value ->
            Just value

        _ ->
            Nothing



{-
   BadUrl String
     | Timeout
     | NetworkError
     | BadStatus Int
     | BadBody String
-}


fromHttpResult : Result Http.Error value -> Data value
fromHttpResult result =
    case result of
        Ok value ->
            Success value

        Err (Http.BadUrl _) ->
            Failure "URL was invalid."

        Err Http.Timeout ->
            Failure "Request timed out."

        Err Http.NetworkError ->
            Failure "Couldn't connect to internet."

        Err (Http.BadStatus status) ->
            Failure ("Got status " ++ String.fromInt status)

        Err (Http.BadBody reason) ->
            Failure reason


view :
    Data value
    ->
        { notAsked : result
        , loading : result
        , failure : String -> result
        , success : value -> result
        }
    -> result
view data views =
    case data of
        NotAsked ->
            views.notAsked

        Loading ->
            views.loading

        Failure reason ->
            views.failure reason

        Success value ->
            views.success value


isResolved : Data value -> Bool
isResolved data =
    case data of
        NotAsked ->
            False

        Loading ->
            False

        Success _ ->
            True

        Failure _ ->
            True


isUnresolved : Data value -> Bool
isUnresolved =
    not << isResolved

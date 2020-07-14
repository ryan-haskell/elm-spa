port module Ports exposing
    ( clearToken
    , storeToken
    )

-- A place to interact with JavaScript
-- https://guide.elm-lang.org/interop/ports.html


port storeToken : String -> Cmd msg


port clearToken : () -> Cmd msg

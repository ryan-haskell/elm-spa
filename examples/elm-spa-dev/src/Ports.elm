port module Ports exposing (log)

-- A place to interact with JavaScript
-- https://guide.elm-lang.org/interop/ports.html


port log : String -> Cmd msg

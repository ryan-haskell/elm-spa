module Utils.Cmd exposing (send)

import Task


send : msg -> Cmd msg
send =
    Task.succeed >> Task.perform identity

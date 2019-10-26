module Internals.Utils exposing
    ( delay
    , send
    )

import Process
import Task


delay : Int -> msg -> Cmd msg
delay ms msg =
    Process.sleep (toFloat ms)
        |> Task.perform (\_ -> msg)


send : msg -> Cmd msg
send =
    Task.succeed >> Task.perform identity

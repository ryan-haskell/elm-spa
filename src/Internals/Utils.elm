module Internals.Utils exposing (delay)

import Process
import Task


delay : Int -> msg -> Cmd msg
delay ms msg =
    Process.sleep (toFloat ms)
        |> Task.perform (\_ -> msg)

module Utils.Cmd exposing (delay)

import Process
import Task


delay : Float -> msg -> Cmd msg
delay ms msg =
    Process.sleep ms
        |> Task.map (\_ -> msg)
        |> Task.perform identity

module Utils.Cmd exposing (delay, send)

import Process
import Task


send : msg -> Cmd msg
send =
    delay 0


delay : Int -> msg -> Cmd msg
delay ms msg =
    Process.sleep (toFloat ms)
        |> Task.map (\_ -> msg)
        |> Task.perform identity

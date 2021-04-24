port module Ports exposing (load, save)

import Json.Decode as Json
import Storage exposing (Storage)


save : Storage -> Cmd msg
save =
    Storage.save >> save_


load : (Storage -> msg) -> Sub msg
load fromStorage =
    load_ (\json -> Storage.load json |> fromStorage)


port save_ : Json.Value -> Cmd msg


port load_ : (Json.Value -> msg) -> Sub msg

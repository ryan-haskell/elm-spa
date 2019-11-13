port module Ports exposing (sendFiles)

import File exposing (File)
import Json.Encode as Json


port outgoing :
    { message : String
    , data : Json.Value
    }
    -> Cmd msg


sendFiles : List File -> Cmd msg
sendFiles files =
    outgoing
        { message = "sendFiles"
        , data = Json.list File.encode files
        }

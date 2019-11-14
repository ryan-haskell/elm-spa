port module Ports exposing (generate)

import File exposing (File)
import Json.Encode as Json


port outgoing :
    { message : String
    , data : Json.Value
    }
    -> Cmd msg


generate : List File -> Cmd msg
generate files =
    outgoing
        { message = "generate"
        , data = Json.list File.encode files
        }

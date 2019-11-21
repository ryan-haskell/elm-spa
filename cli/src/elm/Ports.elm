port module Ports exposing
    ( createFiles
    , error
    )

import File exposing (File)
import Json.Encode as Json


port outgoing :
    { message : String
    , data : Json.Value
    }
    -> Cmd msg


createFiles : List File -> Cmd msg
createFiles files =
    outgoing
        { message = "createFiles"
        , data = Json.list File.encode files
        }


error : String -> Cmd msg
error reason =
    outgoing
        { message = "error"
        , data = Json.string reason
        }

port module Ports exposing (scrollTo)

import Json.Encode as Json


port outgoing : { action : String, data : Json.Value } -> Cmd msg


scrollTo : String -> Cmd msg
scrollTo id =
    outgoing
        { action = "SCROLL_TO"
        , data = Json.string id
        }

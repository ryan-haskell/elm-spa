port module Ports exposing (alert, scrollTo)

import Json.Encode as Json


port outgoing : { action : String, data : Json.Value } -> Cmd msg


scrollTo : String -> Cmd msg
scrollTo id =
    outgoing
        { action = "SCROLL_TO"
        , data = Json.string id
        }


alert : String -> Cmd msg
alert message =
    outgoing
        { action = "ALERT"
        , data = Json.string message
        }

port module Ports exposing (scrollToTop)

import Json.Encode as Json


port outgoing : { action : String, data : Json.Value } -> Cmd msg


scrollToTop : Cmd msg
scrollToTop =
    outgoing
        { action = "SCROLL_TO_TOP"
        , data = Json.null
        }

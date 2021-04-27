port module Ports exposing (onUrlChange)

import Json.Decode as Json


port onUrlChange : () -> Cmd msg

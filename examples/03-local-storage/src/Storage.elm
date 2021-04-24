module Storage exposing
    ( Storage, save, load
    , increment, decrement
    )

{-|

@docs Storage, save, load
@docs increment, decrement

-}

import Json.Decode as Json
import Json.Encode as Encode


type alias Storage =
    { counter : Int
    }


load : Json.Value -> Storage
load json =
    json
        |> Json.decodeValue decoder
        |> Result.withDefault init


init : Storage
init =
    { counter = 0
    }


decoder : Json.Decoder Storage
decoder =
    Json.map Storage
        (Json.field "counter" Json.int)


save : Storage -> Json.Value
save storage =
    Encode.object
        [ ( "counter", Encode.int storage.counter )
        ]



-- UPDATING STORAGE


increment : Storage -> Storage
increment storage =
    { storage | counter = storage.counter + 1 }


decrement : Storage -> Storage
decrement storage =
    { storage | counter = storage.counter - 1 }

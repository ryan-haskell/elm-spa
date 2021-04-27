port module Storage exposing
    ( Storage, fromJson, onChange
    , increment, decrement
    )

{-|

@docs Storage, fromJson, onChange
@docs increment, decrement

-}

import Json.Decode as Json
import Json.Encode as Encode



-- PORTS


port save : Json.Value -> Cmd msg


port load : (Json.Value -> msg) -> Sub msg



-- STORAGE


type alias Storage =
    { counter : Int
    }



-- Converting to JSON


toJson : Storage -> Json.Value
toJson storage =
    Encode.object
        [ ( "counter", Encode.int storage.counter )
        ]



-- Converting from JSON


fromJson : Json.Value -> Storage
fromJson json =
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



-- Updating storage


increment : Storage -> Cmd msg
increment storage =
    { storage | counter = storage.counter + 1 }
        |> toJson
        |> save


decrement : Storage -> Cmd msg
decrement storage =
    { storage | counter = storage.counter - 1 }
        |> toJson
        |> save



-- LISTENING FOR STORAGE UPDATES


onChange : (Storage -> msg) -> Sub msg
onChange fromStorage =
    load (\json -> fromJson json |> fromStorage)

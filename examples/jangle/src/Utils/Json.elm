module Utils.Json exposing (base64, withDefault)

import Base64
import Json.Decode as D exposing (Decoder)


withDefault : value -> Decoder value -> Decoder value
withDefault fallback decoder =
    D.oneOf
        [ decoder
        , D.succeed fallback
        ]


base64 : Decoder String
base64 =
    D.string
        |> D.andThen
            (\encodedString ->
                case Base64.decode (String.replace "\n" "" encodedString) of
                    Ok str ->
                        D.succeed str

                    Err reason ->
                        D.fail reason
            )

module Api.Github exposing (get)

import Api.Data exposing (Data)
import Api.Token exposing (Token)
import Http
import Json.Decode exposing (Decoder)
import Json.Encode as Json


get :
    { token : Token
    , query : String
    , decoder : Decoder value
    , toMsg : Data value -> msg
    }
    -> Cmd msg
get options =
    Http.request
        { method = "POST"
        , url = "https://api.github.com/graphql"
        , headers = [ Http.header "Authorization" ("Bearer " ++ Api.Token.toString options.token) ]
        , body =
            Http.jsonBody <|
                Json.object
                    [ ( "query", Json.string options.query )
                    ]
        , expect = Http.expectJson (Api.Data.fromHttpResult >> options.toMsg) options.decoder
        , timeout = Just (1000 * 60)
        , tracker = Nothing
        }

module Api.Markdown exposing (get)

import Api.Data exposing (Data)
import Http


get : { file : String, onResponse : Data String -> msg } -> Cmd msg
get options =
    Http.get
        { url = "/content/" ++ options.file
        , expect = Http.expectString (Api.Data.fromHttpResult >> options.onResponse)
        }

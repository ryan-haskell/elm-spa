module Api.Project exposing (Project, get, readme)

import Api.Data exposing (Data)
import Api.Github
import Api.Token exposing (Token)
import Api.User exposing (User)
import Http
import Iso8601
import Json.Decode as D exposing (Decoder)
import Time
import Utils.Json


type alias Project =
    { name : String
    , url : String
    , description : String
    , updatedAt : Time.Posix
    }


get : { token : Token, toMsg : Data (List Project) -> msg } -> Cmd msg
get options =
    Api.Github.get
        { token = options.token
        , decoder = D.at [ "data", "viewer", "repositories", "nodes" ] (D.list decoder)
        , toMsg = options.toMsg
        , query = """
            query { 
                viewer {
                    repositories(first: 10, affiliations: [OWNER], orderBy: { field: UPDATED_AT, direction: DESC }) {
                        nodes {
                            name,
                            description
                            url,
                            updatedAt
                        }
                    }
                }
            }
        """
        }


decoder : Decoder Project
decoder =
    D.map4 Project
        (D.field "name" D.string)
        (D.field "url" D.string)
        (D.field "description" D.string |> Utils.Json.withDefault "")
        (D.field "updatedAt" Iso8601.decoder)


readme : { user : User, repo : String, toMsg : Data String -> msg } -> Cmd msg
readme options =
    restApiGet
        { token = options.user.token
        , path = "/repos/" ++ options.user.login ++ "/" ++ options.repo ++ "/readme"
        , decoder = D.field "content" Utils.Json.base64
        , toMsg = options.toMsg
        }


restApiGet :
    { token : Token
    , path : String
    , decoder : Decoder value
    , toMsg : Data value -> msg
    }
    -> Cmd msg
restApiGet options =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ Api.Token.toString options.token) ]
        , url = "https://api.github.com" ++ options.path
        , expect = Http.expectJson (Api.Data.fromHttpResult >> options.toMsg) options.decoder
        , body = Http.emptyBody
        , timeout = Just (1000 * 60)
        , tracker = Nothing
        }

module Spa.Url exposing (Url, create)

import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Url


type alias Url params =
    { key : Key
    , params : params
    , query : Dict String String
    , rawUrl : Url.Url
    }


create : params -> Key -> Url.Url -> Url params
create params key url =
    { params = params
    , key = key
    , rawUrl = url
    , query =
        url.query
            |> Maybe.map toQueryDict
            |> Maybe.withDefault Dict.empty
    }


toQueryDict : String -> Dict String String
toQueryDict queryString =
    let
        second : List a -> Maybe a
        second list =
            list |> List.drop 1 |> List.head

        toTuple : List String -> Maybe ( String, String )
        toTuple list =
            Maybe.map2 Tuple.pair
                (List.head list)
                (second list)
    in
    queryString
        |> String.split "&"
        |> List.map (String.split "=")
        |> List.filterMap toTuple
        |> Dict.fromList

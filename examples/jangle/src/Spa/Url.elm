module Spa.Url exposing (Url, create)

import Dict exposing (Dict)
import Url


type alias Url params =
    { params : params
    , query : Dict String String
    , rawUrl : Url.Url
    }


create : params -> Url.Url -> Url params
create params url =
    { params = params
    , rawUrl = url
    , query =
        url.query
            |> Maybe.map toQueryDict
            |> Maybe.withDefault Dict.empty
    }



-- INTERNALS
-- Works with parameters like `?key=value` but not things like `?key`
-- You can use `url.rawUrl.query` to handle checking for the second type
-- of query parameter.


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

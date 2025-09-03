module ElmSpa.Request exposing (Request, create)

{-|


# **( These docs are for CLI contributors )**


### If you are using **elm-spa**, check out [the official guide](https://elm-spa.dev/guide) instead!

---

Every page gets access to a **request**, which has information about the
current URL, route parameters, query parameters etc.

    page : Shared.Model -> Request Params -> Page Model Msg
    page _ request =
        Page.element
            { init = init
            , update = update
            , view = view request
            }

You can choose to pass this request into `init`,`update`, or any other function
that might need access to URL-related information.


# Requests

@docs Request, create

-}

import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Url exposing (Url)


{-| Here is an example request for the route `/people/:name`

    -- /people/ryan
    req.route == Route.People__Detail_ { name = "ryan" }

    req.params == { name = "ryan" }

    req.params.name == "ryan"

    req.query == Dict.empty

And another example with a some query parameters:

    -- /people/scott?allowed=false
    req.route == Route.People__Detail_ { name = "scott" }

    req.params == { name = "scott" }

    req.params.name == "scott"

    Dict.get "allowed" req.query == Just "false"

-}
type alias Request route params =
    { url : Url
    , key : Key
    , route : route
    , params : params
    , query : Dict String String
    }


{-| A convenience function for creating requests, used by elm-spa internally.

    request : Request Route { name : String }
    request =
        Request.create (Route.fromUrl url)
            { name = "ryan" }
            url
            key

-}
create : route -> params -> Url -> Key -> Request route params
create route params url key =
    { url = url
    , key = key
    , params = params
    , route = route
    , query =
        url.query
            |> Maybe.map query
            |> Maybe.withDefault Dict.empty
    }


query : String -> Dict String String
query str =
    if String.isEmpty str then
        Dict.empty

    else
        let
            decode val =
                Url.percentDecode val
                    |> Maybe.withDefault val
        in
        str
            |> String.split "&"
            |> List.filterMap
                (String.split "="
                    >> (\eq ->
                            Maybe.map2 Tuple.pair
                                (List.head eq)
                                (eq |> List.drop 1 |> String.join "=" |> Just)
                       )
                )
            |> List.map (Tuple.mapBoth decode decode)
            |> Dict.fromList

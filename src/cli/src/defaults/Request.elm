module Request exposing (Request, create)

import Browser.Navigation exposing (Key)
import ElmSpa.Request as ElmSpa
import Gen.Route as Route exposing (Route)
import Url exposing (Url)


type alias Request params =
    ElmSpa.Request Route params


create : params -> Url -> Key -> Request params
create params url key =
    ElmSpa.create (Route.fromUrl url) params url key

module Request exposing (Request, create, pushRoute, replaceRoute)

import Browser.Navigation exposing (Key)
import ElmSpa.Request as ElmSpa
import Gen.Route as Route exposing (Route)
import Url exposing (Url)


type alias Request params =
    ElmSpa.Request Route params


create : params -> Url -> Key -> Request params
create params url key =
    ElmSpa.create (Route.fromUrl url) params url key


pushRoute : Route -> Request params -> Cmd msg
pushRoute route req =
    Browser.Navigation.pushUrl req.key (Route.toHref route)


replaceRoute : Route -> Request params -> Cmd msg
replaceRoute route req =
    Browser.Navigation.replaceUrl req.key (Route.toHref route)

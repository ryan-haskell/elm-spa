module Main exposing (main)

import Application exposing (Application)
import Element
import Generated.Pages as Pages
import Generated.Route as Route
import Global


main : Application Global.Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    Application.create
        { ui =
            { map = Element.map
            , toHtml = Element.layout []
            }
        , routing =
            { routes = Route.routes
            , toPath = Route.toPath
            , notFound = Route.NotFound ()
            }
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , page = Pages.page
        }

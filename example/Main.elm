module Main exposing (main)

import App
import Element
import Generated.Pages as Pages
import Generated.Route as Route
import Global
import Pages.NotFound


main : App.Program Global.Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    App.create
        { ui =
            { toHtml = Element.layout []
            , map = Element.map
            }
        , routing =
            { routes = Route.routes
            , toPath = Route.toPath
            , notFound = Route.NotFound {}
            }
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , page = Pages.page
        }

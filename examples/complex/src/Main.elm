module Main exposing (main)

import App
import Element
import Generated.Pages as Pages
import Generated.Routes as Routes
import Global
import Transitions


main : App.Program Global.Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    App.create
        { ui =
            { toHtml = Element.layout []
            , map = Element.map
            }
        , routing =
            { transitions = Transitions.transitions
            , routes = Routes.parsers
            , toPath = Routes.toPath
            , notFound = Routes.routes.notFound
            }
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , page = Pages.page
        }

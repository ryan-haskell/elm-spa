module Main exposing (main)

import Generated.Pages as Pages
import Generated.Routes as Routes exposing (routes)
import Global
import Spa
import Transitions


main : Spa.Program Global.Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    Spa.create
        { ui = Spa.usingElmUi
        , transitions = Transitions.transitions
        , routing =
            { routes = Routes.parsers
            , toPath = Routes.toPath
            , notFound = routes.notFound
            , afterNavigate = Nothing
            }
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , page = Pages.page
        }

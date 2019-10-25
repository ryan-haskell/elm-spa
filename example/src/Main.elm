module Main exposing (main)

import Application exposing (Application)
import Generated.Pages as Pages
import Global
import Layouts.Main


main : Application Global.Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    Application.create
        { routing =
            { routes = Pages.routes
            , notFound = Pages.NotFoundRoute ()
            }
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , layout = Layouts.Main.layout
        , pages =
            { init = Pages.init
            , update = Pages.update
            , bundle = Pages.bundle
            }
        }

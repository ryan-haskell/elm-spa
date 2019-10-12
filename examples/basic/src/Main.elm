module Main exposing (main)

import Application exposing (Application)
import Components.Layout as Layout
import Flags exposing (Flags)
import Global
import Pages
import Route


main : Application Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    Application.create
        { routing =
            { transition = 200
            , fromUrl = Route.fromUrl
            , toPath = Route.toPath
            }
        , layout =
            { init = Layout.init
            , update = Layout.update
            , view = Layout.view
            , subscriptions = Layout.subscriptions
            }
        , pages =
            { init = Pages.init
            , update = Pages.update
            , bundle = Pages.bundle
            }
        }

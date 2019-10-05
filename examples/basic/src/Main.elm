module Main exposing (main)

import App
import Application exposing (Application)
import Context
import Flags exposing (Flags)
import Route exposing (Route)


main : Application Flags Context.Model Context.Msg App.Model App.Msg
main =
    Application.create
        { transition = 200
        , context =
            { init = Context.init
            , update = Context.update
            , view = Context.view
            , subscriptions = Context.subscriptions
            }
        , page =
            { init = App.init
            , update = App.update
            , bundle = App.bundle
            }
        , route =
            { fromUrl = Route.fromUrl
            , toPath = Route.toPath
            }
        }

module Main exposing (main)

import Application exposing (Application)
import Generated.Pages as Pages
import Generated.Route as Route
import Layout as Layout


main : Application () Pages.Model Pages.Msg
main =
    Application.create
        { routing =
            { fromUrl = Route.fromUrl
            , toPath = Route.toPath
            , transition = Application.fade 200
            }
        , layout =
            { view = Layout.view
            }
        , pages =
            { init = Pages.init
            , update = Pages.update
            , bundle = Pages.bundle
            }
        }

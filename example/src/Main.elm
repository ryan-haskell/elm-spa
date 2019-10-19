module Main exposing (main)

import Application exposing (Application)
import Generated.Pages as Pages
import Generated.Route as Route
import Layout as Layout


main : Application () Pages.Model Pages.Msg
main =
    Application.create
        { transition = Application.fade 200
        , routing =
            { fromUrl = Route.fromUrl
            , toPath = Route.toPath
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

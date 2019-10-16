module Main exposing (main)

import Application exposing (Application)
import Generated.Pages as Pages
import Generated.Route as Route
import Layout as Layout


type alias Flags =
    ()


main : Application Flags Pages.Model Pages.Msg
main =
    Application.create
        { routing =
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

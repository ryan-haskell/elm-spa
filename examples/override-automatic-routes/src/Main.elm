module Main exposing (main)

import Application
import Application.Route as AppRoute
import Generated.Pages as Pages
import Generated.Route as Route
import Global


main =
    Application.create
        { ui = Application.usingHtml
        , global =
            { init = Global.init
            , update = Global.update
            , subscriptions = Global.subscriptions
            }
        , routing =
            { routes = routes
            , toPath = toPath
            , notFound = Route.NotFound ()
            }
        , page = Pages.page
        }



-- Here we're making sure the generated route doesn't get matched


routes =
    List.concat
        [ [ AppRoute.path "some-page" Route.NotFound ]
        , Route.routes
        , [ AppRoute.path "some-alternate-url" Route.SomePage ]
        ]


toPath route =
    case route of
        Route.SomePage _ ->
            "/some-alternate-url"

        _ ->
            Route.toPath route

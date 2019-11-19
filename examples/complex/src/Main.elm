module Main exposing (main)

import App
import App.Pattern as Pattern
import App.Transition as Transition
import Element
import Generated.Pages as Pages
import Generated.Routes as Routes
import Global


main : App.Program Global.Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    App.create
        { ui =
            { toHtml = Element.layout []
            , map = Element.map
            }
        , routing =
            { transition = Transition.fadeUi 300
            , patterns =
                [ ( [], Transition.fadeUi 300 )
                , ( [ Pattern.static "guide" ], Transition.fadeUi 3000 )
                , ( [ Pattern.static "docs" ], Transition.fadeUi 200 )
                ]
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

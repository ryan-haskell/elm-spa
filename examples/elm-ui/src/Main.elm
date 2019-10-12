module Main exposing (main)

import Application
import Components.Layout as Layout
import Element
import Flags exposing (Flags)
import Global
import Pages
import Route


main : Application.Program Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    Application.createWith
        { toLayout =
            Element.layout
                [ Element.height Element.fill
                , Element.width Element.fill
                ]
        , fromAttribute = Element.htmlAttribute
        , map = Element.map
        , node = Element.column
        }
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
        |> Application.start

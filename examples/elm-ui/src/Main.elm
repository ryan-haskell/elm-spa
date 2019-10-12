module Main exposing (main)

import Application
import Components.Layout as Layout
import Element exposing (Element)
import Flags exposing (Flags)
import Global
import Html exposing (Html)
import Pages
import Route


main : Application.Program Flags Global.Model Global.Msg Pages.Model Pages.Msg
main =
    Application.createWith
        layout
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


layout : Adapters a b
layout =
    { toLayout = Element.layout [ Element.height Element.fill, Element.width Element.fill ]
    , fromAttribute = Element.htmlAttribute
    , map = Element.map
    , node = Element.column
    }


type alias Adapters a b =
    { toLayout : Element b -> Html b
    , fromAttribute : Html.Attribute b -> Element.Attribute b
    , map : (a -> b) -> Element a -> Element b
    , node : List (Element.Attribute b) -> List (Element b) -> Element b
    }

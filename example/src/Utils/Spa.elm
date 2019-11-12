module Utils.Spa exposing
    ( Bundle
    , Init
    , Page
    , Recipe
    , Update
    , layout
    , recipe
    )

import App.Page
import App.Types
import Element exposing (Element)
import Global


type alias Page params model msg layoutModel layoutMsg appMsg =
    App.Types.Page params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Recipe params model msg layoutModel layoutMsg appMsg =
    App.Types.Recipe params model msg layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Init model msg =
    App.Types.Init model msg Global.Model Global.Msg


type alias Update model msg =
    App.Types.Update model msg Global.Model Global.Msg


type alias Bundle msg appMsg =
    App.Types.Bundle msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)


layout config =
    App.Page.layout
        { map = Element.map
        , view = config.view
        , recipe = config.recipe
        }


recipe config =
    App.Page.recipe
        { map = Element.map
        , page = config.page
        , toModel = config.toModel
        , toMsg = config.toMsg
        }

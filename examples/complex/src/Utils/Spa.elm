module Utils.Spa exposing
    ( Bundle
    , Init
    , LayoutContext
    , Page
    , PageContext
    , Recipe
    , Update
    , layout
    , recipe
    )

import App.Page
import App.Types
import Element exposing (Element)
import Generated.Routes as Routes exposing (Route)
import Global


type alias Page params model msg layoutModel layoutMsg appMsg =
    App.Types.Page Route params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Recipe params model msg layoutModel layoutMsg appMsg =
    App.Types.Recipe Route params model msg layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Init model msg =
    App.Types.Init Route model msg Global.Model Global.Msg


type alias Update model msg =
    App.Types.Update Route model msg Global.Model Global.Msg


type alias Bundle msg appMsg =
    App.Types.Bundle Route msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Layout params model msg appMsg =
    App.Types.Layout Route params model msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Upgrade params model msg layoutModel layoutMsg appMsg =
    App.Types.Upgrade Route params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


type alias LayoutContext msg =
    App.Types.LayoutContext Route msg (Element msg) Global.Model Global.Msg


type alias PageContext =
    App.Types.PageContext Route Global.Model


layout :
    Layout params model msg appMsg
    -> Page params model msg layoutModel layoutMsg appMsg
layout =
    App.Page.layout Element.map


recipe :
    Upgrade params model msg layoutModel layoutMsg appMsg
    -> Recipe params model msg layoutModel layoutMsg appMsg
recipe =
    App.Page.recipe Element.map

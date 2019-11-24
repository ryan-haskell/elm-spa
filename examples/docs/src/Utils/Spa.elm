module Utils.Spa exposing
    ( Bundle
    , Init
    , LayoutContext
    , Page
    , PageContext
    , Recipe
    , Transitions
    , Update
    , layout
    , recipe
    )

import Element exposing (Element)
import Generated.Routes as Routes exposing (Route)
import Global
import Spa.Page
import Spa.Types


type alias Page params model msg layoutModel layoutMsg appMsg =
    Spa.Types.Page Route params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Recipe params model msg layoutModel layoutMsg appMsg =
    Spa.Types.Recipe Route params model msg layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


type alias Init model msg =
    Spa.Types.Init Route model msg Global.Model Global.Msg


type alias Update model msg =
    Spa.Types.Update Route model msg Global.Model Global.Msg


type alias Bundle msg appMsg =
    Spa.Types.Bundle Route msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)


type alias LayoutContext msg =
    Spa.Types.LayoutContext Route msg (Element msg) Global.Model Global.Msg


type alias PageContext =
    Spa.Types.PageContext Route Global.Model


type alias Layout params model msg appMsg =
    Spa.Types.Layout Route params model msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)


layout :
    Layout params model msg appMsg
    -> Page params model msg layoutModel layoutMsg appMsg
layout =
    Spa.Page.layout Element.map


type alias Upgrade params model msg layoutModel layoutMsg appMsg =
    Spa.Types.Upgrade Route params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)


recipe :
    Upgrade params model msg layoutModel layoutMsg appMsg
    -> Recipe params model msg layoutModel layoutMsg appMsg
recipe =
    Spa.Page.recipe Element.map


type alias Transitions msg =
    Spa.Types.Transitions (Element msg)

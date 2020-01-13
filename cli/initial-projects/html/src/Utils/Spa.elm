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

import Html exposing (Html)
import Generated.Routes as Routes exposing (Route)
import Global
import Spa.Page
import Spa.Types


type alias Page params model msg layoutModel layoutMsg appMsg =
    Spa.Types.Page Route params model msg (Html msg) layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


type alias Recipe params model msg layoutModel layoutMsg appMsg =
    Spa.Types.Recipe Route params model msg layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


type alias Init model msg =
    Spa.Types.Init Route model msg Global.Model Global.Msg


type alias Update model msg =
    Spa.Types.Update Route model msg Global.Model Global.Msg


type alias Bundle msg appMsg =
    Spa.Types.Bundle Route msg (Html msg) Global.Model Global.Msg appMsg (Html appMsg)


type alias LayoutContext msg =
    Spa.Types.LayoutContext Route msg (Html msg) Global.Model Global.Msg


type alias PageContext =
    Spa.Types.PageContext Route Global.Model


type alias Layout params model msg appMsg =
    Spa.Types.Layout Route params model msg (Html msg) Global.Model Global.Msg appMsg (Html appMsg)


layout :
    Layout params model msg appMsg
    -> Page params model msg layoutModel layoutMsg appMsg
layout =
    Spa.Page.layout Html.map


type alias Upgrade params model msg layoutModel layoutMsg appMsg =
    Spa.Types.Upgrade Route params model msg (Html msg) layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


recipe :
    Upgrade params model msg layoutModel layoutMsg appMsg
    -> Recipe params model msg layoutModel layoutMsg appMsg
recipe =
    Spa.Page.recipe Html.map


type alias Transitions msg =
    Spa.Types.Transitions (Html msg)

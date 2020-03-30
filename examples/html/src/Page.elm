module Page exposing
    ( Page, Document, Bundle
    , upgrade
    , static, sandbox, element, component
    )

{-|

@docs Page, Document, Bundle

@docs upgrade

@docs static, sandbox, element, component

-}

import Browser
import Global
import Spa


type alias Document msg =
    Browser.Document msg


type alias Page flags model msg =
    Spa.Page flags model msg Global.Model Global.Msg


type alias Bundle msg =
    Spa.Bundle msg


upgrade :
    (pageModel -> model)
    -> (pageMsg -> msg)
    -> Page pageFlags pageModel pageMsg
    ->
        { init : pageFlags -> Global.Model -> ( model, Cmd msg, Cmd Global.Msg )
        , update : pageMsg -> pageModel -> Global.Model -> ( model, Cmd msg, Cmd Global.Msg )
        , bundle : pageModel -> Global.Model -> Bundle msg
        }
upgrade =
    Spa.upgrade


static : { view : Document msg } -> Page flags () msg
static =
    Spa.static


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> Document msg
    }
    -> Page flags model msg
sandbox =
    Spa.sandbox


element :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Document msg
    }
    -> Page flags model msg
element =
    Spa.element


component :
    { init : Global.Model -> flags -> ( model, Cmd msg, Cmd Global.Msg )
    , update : Global.Model -> msg -> model -> ( model, Cmd msg, Cmd Global.Msg )
    , subscriptions : Global.Model -> model -> Sub msg
    , view : Global.Model -> model -> Document msg
    }
    -> Page flags model msg
component =
    Spa.component

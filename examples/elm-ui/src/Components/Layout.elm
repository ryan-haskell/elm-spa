module Components.Layout exposing (init, subscriptions, update, view)

import Element exposing (Element)
import Flags exposing (Flags)
import Global
import Route exposing (Route)


init :
    { navigateTo : Route -> Cmd msg
    , route : Route
    , flags : Flags
    }
    -> ( Global.Model, Cmd Global.Msg, Cmd msg )
init _ =
    ( {}
    , Cmd.none
    , Cmd.none
    )


update :
    { navigateTo : Route -> Cmd msg
    , route : Route
    , flags : Flags
    }
    -> Global.Msg
    -> Global.Model
    -> ( Global.Model, Cmd Global.Msg, Cmd msg )
update _ msg model =
    case msg of
        Global.NoOp ->
            ( model, Cmd.none, Cmd.none )


view :
    { flags : Flags
    , route : Route
    , toMsg : Global.Msg -> msg
    , viewPage : Element msg
    }
    -> Global.Model
    -> Element msg
view { viewPage } _ =
    viewPage


subscriptions :
    { navigateTo : Route -> Cmd msg
    , route : Route
    , flags : Flags
    }
    -> Global.Model
    -> Sub Global.Msg
subscriptions _ _ =
    Sub.none

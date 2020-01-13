module Global exposing
    ( Device(..)
    , Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Browser.Dom as Dom
import Browser.Events as Events
import Generated.Routes exposing (Route)
import Ports
import Task


type alias Flags =
    ()


type alias Model =
    { device : Device
    }


type Device
    = Mobile
    | Desktop


type Msg
    = ScreenResized Int Int
    | GotViewport Dom.Viewport
    | AfterNavigate { old : Route, new : Route }


type alias GlobalContext msg =
    { navigate : Route -> Cmd msg
    }


init : GlobalContext msg -> Flags -> ( Model, Cmd Msg, Cmd msg )
init _ _ =
    ( { device = Desktop
      }
    , Task.perform GotViewport Dom.getViewport
    , Cmd.none
    )


update : GlobalContext msg -> Msg -> Model -> ( Model, Cmd Msg, Cmd msg )
update _ msg model =
    case msg of
        AfterNavigate _ ->
            ( model
            , Cmd.none
            , Ports.scrollToTop
            )

        ScreenResized width _ ->
            ( { model | device = deviceFrom width }
            , Cmd.none
            , Cmd.none
            )

        GotViewport { viewport } ->
            ( { model | device = deviceFrom (floor viewport.width) }
            , Cmd.none
            , Cmd.none
            )


deviceFrom : Int -> Device
deviceFrom width =
    if width > 715 then
        Desktop

    else
        Mobile


subscriptions : Model -> Sub Msg
subscriptions _ =
    Events.onResize ScreenResized

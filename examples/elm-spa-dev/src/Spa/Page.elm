module Spa.Page exposing
    ( Page
    , static, sandbox, element, application
    , Upgraded, Bundle, upgrade
    )

{-|

@docs Page
@docs static, sandbox, element, application
@docs Upgraded, Bundle, upgrade

-}

import Browser.Navigation exposing (Key)
import Shared
import Spa.Document as Document exposing (Document)
import Spa.Url exposing (Url)
import Url


type alias Page params model msg =
    { init : Shared.Model -> Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    , save : model -> Shared.Model -> Shared.Model
    , load : Shared.Model -> model -> ( model, Cmd msg )
    }


static :
    { view : Url params -> Document msg
    }
    -> Page params (Url params) msg
static page =
    { init = \_ url -> ( url, Cmd.none )
    , update = \_ model -> ( model, Cmd.none )
    , view = page.view
    , subscriptions = \_ -> Sub.none
    , save = always identity
    , load = \_ model -> ( model, Cmd.none )
    }


sandbox :
    { init : Url params -> model
    , update : msg -> model -> model
    , view : model -> Document msg
    }
    -> Page params model msg
sandbox page =
    { init = \_ url -> ( page.init url, Cmd.none )
    , update = \msg model -> ( page.update msg model, Cmd.none )
    , view = page.view
    , subscriptions = \_ -> Sub.none
    , save = always identity
    , load = \_ model -> ( model, Cmd.none )
    }


element :
    { init : Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    }
    -> Page params model msg
element page =
    { init = \_ params -> page.init params
    , update = \msg model -> page.update msg model
    , view = page.view
    , subscriptions = page.subscriptions
    , save = always identity
    , load = \_ model -> ( model, Cmd.none )
    }


application :
    { init : Shared.Model -> Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    , save : model -> Shared.Model -> Shared.Model
    , load : Shared.Model -> model -> ( model, Cmd msg )
    }
    -> Page params model msg
application page =
    page



-- UPGRADING


type alias Upgraded pageParams pageModel pageMsg model msg =
    { init : pageParams -> Shared.Model -> Key -> Url.Url -> ( model, Cmd msg )
    , update : pageMsg -> pageModel -> ( model, Cmd msg )
    , bundle : pageModel -> Bundle model msg
    }


type alias Bundle model msg =
    { view : Document msg
    , subscriptions : Sub msg
    , save : Shared.Model -> Shared.Model
    , load : Shared.Model -> ( model, Cmd msg )
    }


upgrade :
    (pageModel -> model)
    -> (pageMsg -> msg)
    -> Page pageParams pageModel pageMsg
    -> Upgraded pageParams pageModel pageMsg model msg
upgrade toModel toMsg page =
    { init = \params shared key url -> page.init shared (Spa.Url.create params key url) |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , update = \msg model -> page.update msg model |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model ->
            { view = page.view model |> Document.map toMsg
            , subscriptions = page.subscriptions model |> Sub.map toMsg
            , save = page.save model
            , load = \shared -> page.load shared model |> Tuple.mapBoth toModel (Cmd.map toMsg)
            }
    }

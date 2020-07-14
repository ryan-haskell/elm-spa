module Spa.Page exposing
    ( Page
    , static, sandbox, element, application
    )

{-|

@docs Page
@docs static, sandbox, element, application
@docs Upgraded, Bundle, upgrade

-}

import Shared
import Spa.Document exposing (Document)
import Spa.Url exposing (Url)


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
    , load = always (identity >> ignoreEffect)
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
    , load = always (identity >> ignoreEffect)
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
    , load = always (identity >> ignoreEffect)
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


ignoreEffect : model -> ( model, Cmd msg )
ignoreEffect model =
    ( model, Cmd.none )

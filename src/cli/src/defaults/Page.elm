module Page exposing
    ( Page
    , static, sandbox, element, shared
    )

{-|

@docs Page
@docs static, sandbox, element, shared

-}

import ElmSpa.Page
import Shared
import View exposing (View)


type alias Page model msg =
    { init : () -> ( model, Cmd msg, List Shared.Msg )
    , update : msg -> model -> ( model, Cmd msg, List Shared.Msg )
    , view : model -> View msg
    , subscriptions : model -> Sub msg
    }


static :
    { view : View Never
    }
    -> Page () Never
static =
    ElmSpa.Page.static


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> View msg
    }
    -> Page model msg
sandbox =
    ElmSpa.Page.sandbox


element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> View msg
    , subscriptions : model -> Sub msg
    }
    -> Page model msg
element =
    ElmSpa.Page.element


shared :
    { init : ( model, Cmd msg, List Shared.Msg )
    , update : msg -> model -> ( model, Cmd msg, List Shared.Msg )
    , view : model -> View msg
    , subscriptions : model -> Sub msg
    }
    -> Page model msg
shared =
    ElmSpa.Page.shared

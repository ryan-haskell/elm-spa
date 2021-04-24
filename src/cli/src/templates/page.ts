export default (): string => `
module Page exposing
    ( Page, With
    , static, sandbox, element, advanced
    , protected
    )

{-|

@docs Page, With
@docs static, sandbox, element, advanced
@docs protected

-}

import Auth exposing (User)
import Effect exposing (Effect)
import ElmSpa.Internals.Page as ElmSpa
import Gen.Route exposing (Route)
import Request exposing (Request)
import Shared
import View exposing (View)



-- PAGES


type alias Page =
    With () Never


type alias With model msg =
    ElmSpa.Page Shared.Model Route (Effect msg) (View msg) model msg


static :
    { view : View Never
    }
    -> Page
static =
    ElmSpa.static Effect.none


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> View msg
    }
    -> With model msg
sandbox =
    ElmSpa.sandbox Effect.none


element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> View msg
    , subscriptions : model -> Sub msg
    }
    -> With model msg
element =
    ElmSpa.element Effect.fromCmd


advanced :
    { init : ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , view : model -> View msg
    , subscriptions : model -> Sub msg
    }
    -> With model msg
advanced =
    ElmSpa.advanced



-- PROTECTED PAGES


protected :
    { static :
        (User
            ->
            { view : View msg
            }
        )
        -> With () msg
    , sandbox :
        (User
            ->
            { init : model
            , update : msg -> model -> model
            , view : model -> View msg
            }
        )
        -> With model msg
    , element :
        (User
            ->
            { init : ( model, Cmd msg )
            , update : msg -> model -> ( model, Cmd msg )
            , view : model -> View msg
            , subscriptions : model -> Sub msg
            }
        )
        -> With model msg
    , advanced :
        (User
            ->
            { init : ( model, Effect msg )
            , update : msg -> model -> ( model, Effect msg )
            , view : model -> View msg
            , subscriptions : model -> Sub msg
            }
        )
        -> With model msg
    }
protected =
    ElmSpa.protected3
        { effectNone = Effect.none
        , fromCmd = Effect.fromCmd
        , beforeInit = Auth.beforeProtectedInit
        }

`.trimLeft()
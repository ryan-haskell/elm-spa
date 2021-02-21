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


{-| Replace "()" with your actual User type
-}
type alias User =
    ()


{-| This function will run before any `protected` pages.

Here, you can provide logic on where to redirect if a user is not signed in. Here's an example:

    case shared.user of
        Just user ->
            ElmSpa.Provide user

        Nothing ->
            ElmSpa.RedirectTo Gen.Route.SignIn

-}
beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit shared req =
    ElmSpa.RedirectTo Gen.Route.NotFound


protected :
    { static :
        { view : User -> View msg
        }
        -> With () msg
    , sandbox :
        { init : User -> model
        , update : User -> msg -> model -> model
        , view : User -> model -> View msg
        }
        -> With model msg
    , element :
        { init : User -> ( model, Cmd msg )
        , update : User -> msg -> model -> ( model, Cmd msg )
        , view : User -> model -> View msg
        , subscriptions : User -> model -> Sub msg
        }
        -> With model msg
    , advanced :
        { init : User -> ( model, Effect msg )
        , update : User -> msg -> model -> ( model, Effect msg )
        , view : User -> model -> View msg
        , subscriptions : User -> model -> Sub msg
        }
        -> With model msg
    }
protected =
    ElmSpa.protected2
        { effectNone = Effect.none
        , fromCmd = Effect.fromCmd
        , beforeInit = beforeProtectedInit
        }

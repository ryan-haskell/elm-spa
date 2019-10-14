module Application.Sandbox exposing
    ( Application, create
    , Page
    , Static, static
    , Sandbox, sandbox
    , Init, init
    , Update, update, keep
    , Bundle, bundle
    )

{-|

@docs Application, create

@docs Page

@docs Static, static

@docs Sandbox, sandbox

@docs Init, init

@docs Update, update, keep

@docs Bundle, bundle

-}

import Application.Internals.Sandbox.Bundle as Bundle
import Application.Internals.Sandbox.Init as Init
import Application.Internals.Sandbox.Page as Page
import Application.Internals.Sandbox.Update as Update
import Browser



-- APPLICATION


type alias Application model msg =
    Platform.Program () model msg


create :
    { route : route
    , pages :
        { init : route -> Init model
        , update : msg -> model -> Update model
        , bundle : model -> Bundle model msg
        }
    }
    -> Application model msg
create config =
    Browser.sandbox
        { init = Init.create (config.pages.init config.route)
        , update = Update.create config.pages.update
        , view = Bundle.createView config.pages.bundle
        }



-- INIT


type alias Init model =
    Init.Init model


init :
    Page pageModel pageMsg model msg
    -> Init model
init =
    Init.init



-- UPDATE


type alias Update model =
    Update.Update model


update :
    { page : Page pageModel pageMsg model msg
    , model : pageModel
    , msg : pageMsg
    }
    -> Update model
update =
    Update.update


keep : model -> Update model
keep =
    Update.keep



-- BUNDLE


type alias Bundle model msg =
    Bundle.Bundle model msg


bundle :
    { page : Page pageModel pageMsg model msg
    , model : pageModel
    }
    -> Bundle model msg
bundle =
    Bundle.bundle



-- PAGE


type alias Page pageModel pageMsg model msg =
    Page.Page pageModel pageMsg model msg


type alias Static =
    Page.Static


type alias Sandbox pageModel pageMsg =
    Page.Sandbox pageModel pageMsg


static :
    Static
    ->
        { toModel : () -> model
        , toMsg : Never -> msg
        }
    -> Page () Never model msg
static =
    Page.static


sandbox :
    Sandbox pageModel pageMsg
    ->
        { toModel : pageModel -> model
        , toMsg : pageMsg -> msg
        }
    -> Page pageModel pageMsg model msg
sandbox =
    Page.sandbox

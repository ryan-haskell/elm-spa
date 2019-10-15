module Application.Element exposing
    ( Application, create
    , Page
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Init, init
    , Update, update, keep
    , Bundle, bundle
    )

{-|

@docs Application, create

@docs Page

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

@docs Init, init

@docs Update, update, keep

@docs Bundle, bundle

-}

import Application.Internals.Element.Bundle as Bundle
import Application.Internals.Element.Init as Init
import Application.Internals.Element.Page as Page
import Application.Internals.Element.Routing as Routing
import Application.Internals.Element.Update as Update
import Browser



-- APPLICATION


type alias Application route flags model msg =
    Platform.Program flags (Routing.Model route model msg) (Routing.Msg route msg)


create :
    { routing :
        { initial : route
        , routes : List ( String, route )
        }
    , pages :
        { init : route -> Init flags model msg
        , update : msg -> model -> Update model msg
        , bundle : model -> Bundle model msg
        }
    }
    -> Application route flags model msg
create config =
    Browser.element
        { init =
            Routing.init
                { init = Init.create config.pages.init
                , route = config.routing.initial
                }
        , update =
            Routing.update
                { update = Update.create config.pages.update
                }
        , view =
            Routing.view
                { view = Bundle.createView config.pages.bundle
                , routes = config.routing.routes
                }
        , subscriptions =
            Routing.subscriptions
                { subscriptions = Bundle.createSubscriptions config.pages.bundle
                }
        }



-- INIT


type alias Init flags model msg =
    Init.Init flags model msg


init :
    Page flags pageModel pageMsg model msg
    -> Init flags model msg
init =
    Init.init



-- UPDATE


type alias Update model msg =
    Update.Update model msg


update :
    { page : Page flags pageModel pageMsg model msg
    , model : pageModel
    , msg : pageMsg
    }
    -> Update model msg
update =
    Update.update


keep : model -> Update model msg
keep =
    Update.keep



-- BUNDLE


type alias Bundle model msg =
    Bundle.Bundle model msg


bundle :
    { page : Page flags pageModel pageMsg model msg
    , model : pageModel
    }
    -> Bundle model msg
bundle =
    Bundle.bundle



-- PAGE


type alias Page flags pageModel pageMsg model msg =
    Page.Page flags pageModel pageMsg model msg


type alias Static =
    Page.Static


type alias Sandbox pageModel pageMsg =
    Page.Sandbox pageModel pageMsg


type alias Element flags pageModel pageMsg =
    Page.Element flags pageModel pageMsg


static :
    Static
    ->
        { toModel : () -> model
        , toMsg : Never -> msg
        }
    -> Page flags () Never model msg
static =
    Page.static


sandbox :
    Sandbox pageModel pageMsg
    ->
        { toModel : pageModel -> model
        , toMsg : pageMsg -> msg
        }
    -> Page flags pageModel pageMsg model msg
sandbox =
    Page.sandbox


element :
    Element flags pageModel pageMsg
    ->
        { toModel : pageModel -> model
        , toMsg : pageMsg -> msg
        }
    -> Page flags pageModel pageMsg model msg
element =
    Page.element

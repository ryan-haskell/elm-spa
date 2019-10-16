module Application exposing
    ( Application, create
    , Page, Bundle, keep
    , Static, static
    , Sandbox, sandbox
    )

{-|

@docs Application, create

@docs Page, Bundle, keep

@docs Static, static

@docs Sandbox, sandbox

-}

import Browser
import Internals.Page as Page



-- APPLICATION


type alias Application model msg =
    Platform.Program () model msg


create :
    { route : route
    , pages :
        { init : route -> model
        , update : msg -> model -> model
        , bundle : model -> Page.Bundle msg
        }
    }
    -> Application model msg
create config =
    Browser.sandbox
        { init = config.pages.init config.route
        , update = config.pages.update
        , view = config.pages.bundle >> .view
        }



-- PAGE


type alias Page pageModel pageMsg model msg =
    Page.Page pageModel pageMsg model msg


type alias Bundle msg =
    Page.Bundle msg


keep : model -> model
keep =
    identity


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

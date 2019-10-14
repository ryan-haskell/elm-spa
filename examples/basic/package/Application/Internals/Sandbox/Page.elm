module Application.Internals.Sandbox.Page exposing
    ( Page
    , Static, static
    , Sandbox, sandbox
    , unwrap
    )

{-|

@docs Page

@docs Static, static

@docs Sandbox, sandbox

@docs unwrap

-}

import Html exposing (Html)


type Page pageModel pageMsg model msg
    = Page (Page_ pageModel pageMsg model msg)


type alias Page_ pageModel pageMsg model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    , page : Config pageModel pageMsg model msg
    }


type Config pageModel pageMsg model msg
    = StaticConfig Static
    | SandboxConfig (Sandbox pageModel pageMsg)


unwrap :
    Page pageModel pageMsg model msg
    -> Page_ pageModel pageMsg model msg
unwrap (Page page) =
    page



-- STATIC


type alias Static =
    { view : Html Never
    }


static :
    { toModel : () -> model
    , toMsg : Never -> msg
    , page : Static
    }
    -> Page () Never model msg
static page =
    Page
        { toModel = page.toModel
        , toMsg = page.toMsg
        , page = StaticConfig page.page
        }



-- SANDBOX


type alias Sandbox pageModel pageMsg =
    { init : pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    , page : Sandbox pageModel pageMsg
    }
    -> Page pageModel pageMsg model msg
sandbox page =
    Page
        { toModel = page.toModel
        , toMsg = page.toMsg
        , page = SandboxConfig page.page
        }

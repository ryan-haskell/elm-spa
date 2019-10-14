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
    , page : Sandbox pageModel pageMsg
    }


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
    Static
    ->
        { toModel : () -> model
        , toMsg : Never -> msg
        }
    -> Page () Never model msg
static page { toModel, toMsg } =
    Page
        { toModel = toModel
        , toMsg = toMsg
        , page =
            { init = ()
            , update = always identity
            , view = \_ -> Html.map never page.view
            }
        }



-- SANDBOX


type alias Sandbox pageModel pageMsg =
    { init : pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    Sandbox pageModel pageMsg
    ->
        { toModel : pageModel -> model
        , toMsg : pageMsg -> msg
        }
    -> Page pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    Page
        { toModel = toModel
        , toMsg = toMsg
        , page = page
        }

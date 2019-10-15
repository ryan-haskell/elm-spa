module Application.Internals.Element.Page exposing
    ( Page
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , unwrap
    )

{-|

@docs Page

@docs Static, static
@docs Sandbox, sandbox
@docs Element, element

@docs unwrap

-}

import Html exposing (Html)


type Page flags pageModel pageMsg model msg
    = Page (Page_ flags pageModel pageMsg model msg)


type alias Page_ flags pageModel pageMsg model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    , page : Element flags pageModel pageMsg
    }


unwrap :
    Page flags pageModel pageMsg model msg
    -> Page_ flags pageModel pageMsg model msg
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
    -> Page flags () Never model msg
static page { toModel, toMsg } =
    Page
        { toModel = toModel
        , toMsg = toMsg
        , page =
            { init = \_ -> ( (), Cmd.none )
            , update = \_ model -> ( model, Cmd.none )
            , view = \_ -> Html.map never page.view
            , subscriptions = \_ -> Sub.none
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
    -> Page flags pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    Page
        { toModel = toModel
        , toMsg = toMsg
        , page =
            { init = \_ -> ( page.init, Cmd.none )
            , update = \msg model -> ( page.update msg model, Cmd.none )
            , view = page.view
            , subscriptions = \_ -> Sub.none
            }
        }



-- ELEMENT


type alias Element flags pageModel pageMsg =
    { init : flags -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> Html pageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


element :
    Element flags pageModel pageMsg
    ->
        { toModel : pageModel -> model
        , toMsg : pageMsg -> msg
        }
    -> Page flags pageModel pageMsg model msg
element page { toModel, toMsg } =
    Page
        { toModel = toModel
        , toMsg = toMsg
        , page = page
        }

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
    , page :
        { init : flags -> ( pageModel, Cmd pageMsg )
        , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
        , view : pageModel -> Html pageMsg
        , subscriptions : pageModel -> Sub pageMsg
        }
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
    { toModel : () -> model
    , toMsg : Never -> msg
    , page : Static
    }
    -> Page flags () Never model msg
static page =
    Page
        { toModel = page.toModel
        , toMsg = page.toMsg
        , page =
            { init = \_ -> ( (), Cmd.none )
            , update = \_ model -> ( model, Cmd.none )
            , view = \_ -> Html.map never page.page.view
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
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    , page : Sandbox pageModel pageMsg
    }
    -> Page flags pageModel pageMsg model msg
sandbox page =
    Page
        { toModel = page.toModel
        , toMsg = page.toMsg
        , page =
            { init = \_ -> ( page.page.init, Cmd.none )
            , update = \_ model -> ( model, Cmd.none )
            , view = page.page.view
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
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    , page : Element flags pageModel pageMsg
    }
    -> Page flags pageModel pageMsg model msg
element =
    Page

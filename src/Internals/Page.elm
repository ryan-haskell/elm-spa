module Internals.Page exposing
    ( Page, Recipe
    , Bundle
    , Static, static
    , Sandbox, sandbox
    , Element, element
    )

{-|

@docs Page, Recipe

@docs Bundle

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

-}

import Html exposing (Html)


type alias Page params pageModel pageMsg model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    }
    -> Recipe params pageModel pageMsg model msg


type alias Recipe params pageModel pageMsg model msg =
    { init : params -> ( model, Cmd msg )
    , update : pageMsg -> pageModel -> ( model, Cmd msg )
    , bundle : pageModel -> Bundle msg
    }


type alias Bundle msg =
    { view : Html msg
    , subscriptions : Sub msg
    }



-- STATIC


type alias Static =
    { view : Html Never
    }


static :
    Static
    -> Page params () Never model msg
static page { toModel, toMsg } =
    { init = \_ -> ( toModel (), Cmd.none )
    , update = \_ model -> ( toModel model, Cmd.none )
    , bundle =
        \_ ->
            { view = Html.map toMsg page.view
            , subscriptions = Sub.none
            }
    }



-- SANDBOX


type alias Sandbox pageModel pageMsg params =
    { init : params -> pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    Sandbox pageModel pageMsg params
    -> Page params pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    { init = \params -> ( toModel (page.init params), Cmd.none )
    , update =
        \msg model ->
            ( page.update msg model |> toModel
            , Cmd.none
            )
    , bundle =
        \model ->
            { view = page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }



-- ELEMENT


type alias Element pageModel pageMsg params =
    { init : params -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> Html pageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


element :
    Element pageModel pageMsg params
    -> Page params pageModel pageMsg model msg
element page { toModel, toMsg } =
    { init =
        page.init >> Tuple.mapBoth toModel (Cmd.map toMsg)
    , update =
        \msg model ->
            page.update msg model
                |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model ->
            { view = page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }

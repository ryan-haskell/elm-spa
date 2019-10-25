module Internals.Page exposing
    ( Page, Recipe
    , Init, Bundle
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Glue, Pages, glue
    )

{-|

@docs Page, Recipe

@docs Init, Bundle

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

@docs Glue, Pages, glue

-}

import Html exposing (Html)
import Internals.Layout exposing (Layout)


type alias Page pageRoute pageModel pageMsg model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    }
    -> Recipe pageRoute pageModel pageMsg model msg


type alias Recipe pageRoute pageModel pageMsg model msg =
    { init : pageRoute -> Init model msg
    , update : pageMsg -> pageModel -> ( model, Cmd msg )
    , bundle : pageModel -> Bundle msg
    }


type alias Init model msg =
    ( model, Cmd msg )


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
    -> Page pageRoute () Never model msg
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


type alias Sandbox pageRoute pageModel pageMsg =
    { init : pageRoute -> pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    Sandbox pageRoute pageModel pageMsg
    -> Page pageRoute pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    { init =
        \pageRoute ->
            ( toModel (page.init pageRoute), Cmd.none )
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


type alias Element pageRoute pageModel pageMsg =
    { init : pageRoute -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> Html pageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


element :
    Element pageRoute pageModel pageMsg
    -> Page pageRoute pageModel pageMsg model msg
element page { toModel, toMsg } =
    { init =
        page.init
            >> Tuple.mapBoth toModel (Cmd.map toMsg)
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



-- LAYOUT


type alias Glue pageRoute layoutModel layoutMsg =
    { layout : Layout layoutMsg
    , pages : Pages pageRoute layoutModel layoutMsg
    }


type alias Pages pageRoute layoutModel layoutMsg =
    { init : pageRoute -> Init layoutModel layoutMsg
    , update : layoutMsg -> layoutModel -> ( layoutModel, Cmd layoutMsg )
    , bundle : layoutModel -> Bundle layoutMsg
    }


glue :
    Glue pageRoute layoutModel layoutMsg
    -> Page pageRoute layoutModel layoutMsg model msg
glue options { toModel, toMsg } =
    { init =
        options.pages.init
            >> Tuple.mapBoth toModel (Cmd.map toMsg)
    , update =
        \msg model ->
            options.pages.update msg model
                |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model ->
            let
                page =
                    options.pages.bundle model
            in
            { view =
                options.layout.view
                    { page = page.view
                    }
                    |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }

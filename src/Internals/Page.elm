module Internals.Page exposing
    ( Page, Recipe
    , Init, Bundle
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Glue, Pages, glue
    , TransitionStatus(..)
    )

{-|

@docs Page, Recipe

@docs Init, Bundle

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

@docs Glue, Pages, glue

-}

import Html exposing (Html, div, text)
import Internals.Layout exposing (Layout)
import Internals.Transition as Transition


type alias Page params pageModel pageMsg model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    }
    -> Recipe params pageModel pageMsg model msg


type alias Recipe params pageModel pageMsg model msg =
    { init : params -> Init model msg
    , update : pageMsg -> pageModel -> ( model, Cmd msg )
    , bundle : pageModel -> Bundle msg
    }


type TransitionStatus
    = Initial
    | Leaving
    | Entering


type alias Init model msg =
    { parentSpeed : Int
    }
    ->
        { model : model
        , cmd : Cmd msg
        , speed : Int
        }


type alias Bundle msg =
    TransitionStatus
    ->
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
    { init =
        \_ { parentSpeed } ->
            { model = toModel ()
            , cmd = Cmd.none
            , speed = parentSpeed
            }
    , update = \_ model -> ( toModel model, Cmd.none )
    , bundle =
        \_ _ ->
            { view = Html.map toMsg page.view
            , subscriptions = Sub.none
            }
    }



-- SANDBOX


type alias Sandbox params pageModel pageMsg =
    { init : params -> pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    Sandbox params pageModel pageMsg
    -> Page params pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    { init =
        \params { parentSpeed } ->
            { model = toModel (page.init params)
            , cmd = Cmd.none
            , speed = parentSpeed
            }
    , update =
        \msg model ->
            ( page.update msg model |> toModel
            , Cmd.none
            )
    , bundle =
        \model _ ->
            { view = page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }



-- ELEMENT


type alias Element params pageModel pageMsg =
    { init : params -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> Html pageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


element :
    Element params pageModel pageMsg
    -> Page params pageModel pageMsg model msg
element page { toModel, toMsg } =
    { init =
        \params { parentSpeed } ->
            page.init params
                |> (\( model, cmd ) ->
                        { model = toModel model
                        , cmd = Cmd.map toMsg cmd
                        , speed = parentSpeed
                        }
                   )
    , update =
        \msg model ->
            page.update msg model
                |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model _ ->
            { view = page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }



-- LAYOUT


type alias Glue params layoutModel layoutMsg =
    { layout : Layout layoutMsg
    , pages : Pages params layoutModel layoutMsg
    }


type alias Pages params layoutModel layoutMsg =
    { init : params -> Init layoutModel layoutMsg
    , update : layoutMsg -> layoutModel -> ( layoutModel, Cmd layoutMsg )
    , bundle : layoutModel -> Bundle layoutMsg
    }


glue :
    Glue params layoutModel layoutMsg
    -> Page params layoutModel layoutMsg model msg
glue options { toModel, toMsg } =
    { init =
        \params _ ->
            options.pages.init params { parentSpeed = Transition.speed options.layout.transition }
                |> (\page ->
                        { model = toModel page.model
                        , cmd = Cmd.map toMsg page.cmd
                        , speed = page.speed
                        }
                   )
    , update =
        \msg model ->
            options.pages.update msg model
                |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model status ->
            let
                page =
                    options.pages.bundle model status
            in
            { view =
                options.layout.view
                    { page =
                        div []
                            [ text (Debug.toString status)
                            , page.view
                            ]
                    }
                    |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }

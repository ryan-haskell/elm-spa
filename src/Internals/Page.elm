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
import Url.Parser as Parser exposing (Parser)


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


type TransitionStatus
    = Initial
    | Leaving
    | Complete


type alias Init model msg =
    { parentSpeed : Int
    }
    ->
        { model : model
        , cmd : Cmd msg
        , speed : Int
        }


type alias Bundle msg =
    { view : TransitionStatus -> Html msg
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
    { init =
        \_ { parentSpeed } ->
            { model = toModel ()
            , cmd = Cmd.none
            , speed = parentSpeed
            }
    , update = \_ model -> ( toModel model, Cmd.none )
    , bundle =
        \_ ->
            { view = \_ -> Html.map toMsg page.view
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
        \pageRoute { parentSpeed } ->
            { model = toModel (page.init pageRoute)
            , cmd = Cmd.none
            , speed = parentSpeed
            }
    , update =
        \msg model ->
            ( page.update msg model |> toModel
            , Cmd.none
            )
    , bundle =
        \model ->
            { view = \_ -> page.view model |> Html.map toMsg
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
        \pageRoute { parentSpeed } ->
            page.init pageRoute
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
        \model ->
            { view = \_ -> page.view model |> Html.map toMsg
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
        \pageRoute _ ->
            options.pages.init pageRoute { parentSpeed = Transition.speed options.layout.transition }
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
        \model ->
            let
                page =
                    options.pages.bundle model
            in
            { view =
                \status ->
                    options.layout.view
                        { page = page.view status
                        }
                        |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }

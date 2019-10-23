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


type alias Page params pageModel pageMsg route model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    , toRoute : params -> route
    }
    -> Recipe params pageModel pageMsg route model msg


type alias Route params route =
    Parser (params -> route) route


type alias Recipe params pageModel pageMsg route model msg =
    { route : Parser (route -> route) route
    , init : params -> Init model msg
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


type alias Static params route =
    { view : Html Never
    , route : Route params route
    }


static :
    Static params route
    -> Page params () Never route model msg
static page { toModel, toMsg, toRoute } =
    { route = Parser.map toRoute page.route
    , init =
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


type alias Sandbox params pageModel pageMsg route =
    { route : Route params route
    , init : params -> pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    Sandbox params pageModel pageMsg route
    -> Page params pageModel pageMsg route model msg
sandbox page { toModel, toMsg, toRoute } =
    { route = Parser.map toRoute page.route
    , init =
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
        \model ->
            { view = \_ -> page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }



-- ELEMENT


type alias Element params pageModel pageMsg route =
    { route : Route params route
    , init : params -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> Html pageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


element :
    Element params pageModel pageMsg route
    -> Page params pageModel pageMsg route model msg
element page { toModel, toMsg, toRoute } =
    { route = Parser.map toRoute page.route
    , init =
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
        \model ->
            { view = \_ -> page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }



-- LAYOUT


type alias Glue params layoutModel layoutMsg route =
    { route : Route params route
    , layout : Layout layoutMsg
    , pages : Pages params layoutModel layoutMsg
    }


type alias Pages params layoutModel layoutMsg =
    { init : params -> Init layoutModel layoutMsg
    , update : layoutMsg -> layoutModel -> ( layoutModel, Cmd layoutMsg )
    , bundle : layoutModel -> Bundle layoutMsg
    }


glue :
    Glue params layoutModel layoutMsg route
    -> Page params layoutModel layoutMsg route model msg
glue options { toModel, toMsg, toRoute } =
    { route = Parser.map toRoute options.route
    , init =
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
        \model ->
            let
                page =
                    options.pages.bundle model
            in
            { view =
                \status ->
                    options.layout.view
                        { page =
                            div []
                                [ text (Debug.toString status)
                                , page.view status
                                ]
                        }
                        |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }

module Application.Page exposing
    ( Page, Recipe
    , Init, Update, Bundle, keep
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Component, component
    , Layout, LayoutOptions, layout
    )

{-|

@docs Page, Recipe

@docs Init, Update, Bundle, keep

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

@docs Component, component

@docs Layout, LayoutOptions, layout

-}

import Application.Transition exposing (Transition)
import Html exposing (Html)


type alias Page pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg =
    { toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    }
    -> Recipe pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg


type alias Recipe pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg =
    { init : pageRoute -> Init layoutModel layoutMsg globalModel globalMsg
    , update : pageMsg -> pageModel -> Update layoutModel layoutMsg globalModel globalMsg
    , bundle : pageModel -> Bundle layoutMsg globalModel globalMsg msg
    }


type alias Init layoutModel layoutMsg globalModel globalMsg =
    globalModel
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


type alias Update layoutModel layoutMsg globalModel globalMsg =
    globalModel
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


keep : layoutModel -> Update layoutModel layoutMsg globalModel globalMsg
keep model =
    always ( model, Cmd.none, Cmd.none )


type alias Bundle layoutMsg globalModel globalMsg msg =
    globalModel
    ->
        { fromGlobalMsg : globalMsg -> msg
        , fromPageMsg : layoutMsg -> msg
        }
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
    -> Page pageRoute () Never layoutModel layoutMsg globalModel globalMsg msg
static page { toModel, toMsg } =
    { init = \_ _ -> ( toModel (), Cmd.none, Cmd.none )
    , update = \_ model _ -> ( toModel model, Cmd.none, Cmd.none )
    , bundle =
        \_ _ private ->
            { view = page.view |> Html.map (toMsg >> private.fromPageMsg)
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
    -> Page pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg
sandbox page { toModel, toMsg } =
    { init =
        \pageRoute _ ->
            ( toModel (page.init pageRoute)
            , Cmd.none
            , Cmd.none
            )
    , update =
        \msg model _ ->
            ( page.update msg model |> toModel
            , Cmd.none
            , Cmd.none
            )
    , bundle =
        \model _ private ->
            { view = page.view model |> Html.map (toMsg >> private.fromPageMsg)
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
    -> Page pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg
element page { toModel, toMsg } =
    { init =
        \pageRoute _ ->
            page.init pageRoute
                |> upgrade toModel toMsg
    , update =
        \msg model _ ->
            page.update msg model
                |> upgrade toModel toMsg
    , bundle =
        \model _ private ->
            { view = page.view model |> Html.map (toMsg >> private.fromPageMsg)
            , subscriptions = page.subscriptions model |> Sub.map (toMsg >> private.fromPageMsg)
            }
    }



-- LAYOUT


type alias Layout pageRoute pageModel pageMsg globalModel globalMsg msg =
    { layout : LayoutOptions globalModel msg
    , pages : Recipe pageRoute pageModel pageMsg pageModel pageMsg globalModel globalMsg msg
    }


type alias LayoutOptions globalModel msg =
    { transition : Transition (Html msg)
    , view :
        { page : Html msg
        , global : globalModel
        }
        -> Html msg
    }


layout :
    Layout pageRoute pageModel pageMsg globalModel globalMsg msg
    -> Page pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg
layout options { toModel, toMsg } =
    { init =
        \pageRoute context ->
            options.pages.init pageRoute context
                |> truple toModel toMsg
    , update =
        \msg model context ->
            options.pages.update msg model context
                |> truple toModel toMsg
    , bundle =
        \model global private ->
            let
                bundle =
                    options.pages.bundle
                        model
                        global
                        { fromGlobalMsg = private.fromGlobalMsg
                        , fromPageMsg = toMsg >> private.fromPageMsg
                        }
            in
            { view =
                options.layout.view
                    { page = bundle.view
                    , global = global
                    }
            , subscriptions = bundle.subscriptions
            }
    }



-- COMPONENT


type alias Component pageRoute pageModel pageMsg globalModel globalMsg =
    { init : globalModel -> pageRoute -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , update : globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , subscriptions : globalModel -> pageModel -> Sub pageMsg
    , view : globalModel -> pageModel -> Html pageMsg
    }


component :
    Component pageRoute pageModel pageMsg globalModel globalMsg
    -> Page pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg
component page { toModel, toMsg } =
    { init =
        \pageRoute global ->
            page.init global pageRoute
                |> truple toModel toMsg
    , update =
        \msg model global ->
            page.update global msg model
                |> truple toModel toMsg
    , bundle =
        \model global private ->
            { view = page.view global model |> Html.map (toMsg >> private.fromPageMsg)
            , subscriptions = page.subscriptions global model |> Sub.map (toMsg >> private.fromPageMsg)
            }
    }



-- UTILS


upgrade :
    (model -> bigModel)
    -> (msg -> bigMsg)
    -> ( model, Cmd msg )
    -> ( bigModel, Cmd bigMsg, Cmd a )
upgrade toModel toMsg ( model, cmd ) =
    ( toModel model
    , Cmd.map toMsg cmd
    , Cmd.none
    )


truple :
    (model -> bigModel)
    -> (msg -> bigMsg)
    -> ( model, Cmd msg, Cmd a )
    -> ( bigModel, Cmd bigMsg, Cmd a )
truple toModel toMsg ( a, b, c ) =
    ( toModel a, Cmd.map toMsg b, c )

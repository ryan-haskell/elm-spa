module Application.Page exposing
    ( Page, Recipe
    , Init, Update, Bundle, keep
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Component, component
    , Layout, layout
    )

{-|

@docs Page, Recipe

@docs Init, Update, Bundle, keep

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

@docs Component, component

@docs Layout, layout

-}

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
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


type alias Update layoutModel layoutMsg globalModel globalMsg =
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


keep : layoutModel -> Update layoutModel layoutMsg globalModel globalMsg
keep model =
    always ( model, Cmd.none, Cmd.none )


type alias Bundle layoutMsg globalModel globalMsg msg =
    { global : globalModel
    , fromGlobalMsg : globalMsg -> msg
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
        \_ context ->
            { view = page.view |> Html.map (toMsg >> context.fromPageMsg)
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
        \model context ->
            { view = page.view model |> Html.map (toMsg >> context.fromPageMsg)
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
        \model context ->
            { view = page.view model |> Html.map (toMsg >> context.fromPageMsg)
            , subscriptions = page.subscriptions model |> Sub.map (toMsg >> context.fromPageMsg)
            }
    }



-- LAYOUT


type alias Layout pageRoute pageModel pageMsg globalModel globalMsg msg =
    { layout :
        { page : Html msg
        , global : globalModel
        }
        -> Html msg
    , pages : Recipe pageRoute pageModel pageMsg pageModel pageMsg globalModel globalMsg msg
    }


layout :
    Layout pageRoute pageModel pageMsg globalModel globalMsg msg
    -> Page pageRoute pageModel pageMsg layoutModel layoutMsg globalModel globalMsg msg
layout options { toModel, toMsg } =
    { init =
        \pageRoute global ->
            options.pages.init pageRoute global
                |> truple toModel toMsg
    , update =
        \msg model global ->
            options.pages.update msg model global
                |> truple toModel toMsg
    , bundle =
        \model context ->
            let
                bundle : { view : Html msg, subscriptions : Sub msg }
                bundle =
                    options.pages.bundle
                        model
                        { fromGlobalMsg = context.fromGlobalMsg
                        , fromPageMsg = toMsg >> context.fromPageMsg
                        , global = context.global
                        }
            in
            { view =
                options.layout
                    { page = bundle.view
                    , global = context.global
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
        \pageRoute context ->
            page.init context.global pageRoute
                |> truple toModel toMsg
    , update =
        \msg model context ->
            page.update context.global msg model
                |> truple toModel toMsg
    , bundle =
        \model context ->
            { view = page.view context.global model |> Html.map (toMsg >> context.fromPageMsg)
            , subscriptions = page.subscriptions context.global model |> Sub.map (toMsg >> context.fromPageMsg)
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

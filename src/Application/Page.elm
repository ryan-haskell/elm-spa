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


type alias Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg =
    { toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    , map : (pageMsg -> layoutMsg) -> htmlPageMsg -> htmlLayoutMsg
    }
    -> Recipe pageRoute pageModel pageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg


type alias Recipe pageRoute pageModel pageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg =
    { init : pageRoute -> Init layoutModel layoutMsg globalModel globalMsg
    , update : pageMsg -> pageModel -> Update layoutModel layoutMsg globalModel globalMsg
    , bundle : pageModel -> Bundle layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
    }


type alias Init layoutModel layoutMsg globalModel globalMsg =
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


type alias Update layoutModel layoutMsg globalModel globalMsg =
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


type alias Bundle layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg =
    { global : globalModel
    , fromGlobalMsg : globalMsg -> msg
    , fromPageMsg : layoutMsg -> msg
    , map : (layoutMsg -> msg) -> htmlLayoutMsg -> htmlMsg
    }
    ->
        { title : String
        , view : htmlMsg
        , subscriptions : Sub msg
        }


keep : layoutModel -> Update layoutModel layoutMsg globalModel globalMsg
keep model =
    always ( model, Cmd.none, Cmd.none )



-- STATIC


type alias Static htmlPageMsg =
    { title : String
    , view : htmlPageMsg
    }


static :
    Static htmlPageMsg
    -> Page pageRoute () Never htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
static page { toModel, toMsg, map } =
    { init = \_ _ -> ( toModel (), Cmd.none, Cmd.none )
    , update = \_ model _ -> ( toModel model, Cmd.none, Cmd.none )
    , bundle =
        \_ context ->
            { title = page.title
            , view = page.view |> map toMsg |> context.map context.fromPageMsg
            , subscriptions = Sub.none
            }
    }



-- SANDBOX


type alias Sandbox pageRoute pageModel pageMsg htmlPageMsg =
    { title : pageModel -> String
    , init : pageRoute -> pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> htmlPageMsg
    }


sandbox :
    Sandbox pageRoute pageModel pageMsg htmlPageMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
sandbox page { toModel, toMsg, map } =
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
            { title = page.title model
            , view = page.view model |> map toMsg |> context.map context.fromPageMsg
            , subscriptions = Sub.none
            }
    }



-- ELEMENT


type alias Element pageRoute pageModel pageMsg htmlPageMsg =
    { title : pageModel -> String
    , init : pageRoute -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> htmlPageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


element :
    Element pageRoute pageModel pageMsg htmlPageMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
element page { toModel, toMsg, map } =
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
            { title = page.title model
            , view = page.view model |> map toMsg |> context.map context.fromPageMsg
            , subscriptions = page.subscriptions model |> Sub.map (toMsg >> context.fromPageMsg)
            }
    }



-- LAYOUT


type alias Layout pageRoute pageModel pageMsg globalModel globalMsg msg htmlPageMsg htmlMsg =
    { map : (pageMsg -> msg) -> htmlPageMsg -> htmlMsg
    , layout :
        { page : htmlMsg
        , global : globalModel
        }
        -> htmlMsg
    , pages : Recipe pageRoute pageModel pageMsg pageModel pageMsg htmlPageMsg globalModel globalMsg msg htmlMsg
    }


layout :
    Layout pageRoute pageModel pageMsg globalModel globalMsg msg htmlPageMsg htmlMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
layout options { toModel, toMsg, map } =
    let
        pages =
            options.pages
    in
    { init =
        \pageRoute global ->
            pages.init pageRoute global
                |> truple toModel toMsg
    , update =
        \msg model global ->
            pages.update msg model global
                |> truple toModel toMsg
    , bundle =
        \model context ->
            let
                bundle : { title : String, view : htmlMsg, subscriptions : Sub msg }
                bundle =
                    pages.bundle
                        model
                        { fromGlobalMsg = context.fromGlobalMsg
                        , fromPageMsg = toMsg >> context.fromPageMsg
                        , global = context.global
                        , map = options.map
                        }
            in
            { title = bundle.title
            , view =
                options.layout
                    { page = bundle.view
                    , global = context.global
                    }
            , subscriptions = bundle.subscriptions
            }
    }



-- COMPONENT


type alias Component pageRoute pageModel pageMsg globalModel globalMsg htmlPageMsg =
    { title : globalModel -> pageModel -> String
    , init : globalModel -> pageRoute -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , update : globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , subscriptions : globalModel -> pageModel -> Sub pageMsg
    , view : globalModel -> pageModel -> htmlPageMsg
    }


component :
    Component pageRoute pageModel pageMsg globalModel globalMsg htmlPageMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
component page { toModel, toMsg, map } =
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
            { title = page.title context.global model
            , view = page.view context.global model |> map toMsg |> context.map context.fromPageMsg
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

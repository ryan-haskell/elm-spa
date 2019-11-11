module Application.Page exposing
    ( static
    , sandbox
    , element
    , component
    , layout
    , recipe
    , keep
    , Page
    )

{-| Each page can be as simple or complex as you need:

1.  [Static](#static) - for rendering a simple view

2.  [Sandbox](#sandbox) - for maintaining state, without any side-effects

3.  [Element](#element) - for maintaining state, **with** side-effects

4.  [Component](#component) - for a full-blown page, that can view and update global state


## Static

For rendering a simple view.

    page =
        Page.static
            { title = title
            , view = view
            }

@docs static


## Sandbox

For maintaining state, without any side-effects.

    page =
        Page.sandbox
            { title = title
            , init = init
            , update = update
            , view = view
            }

@docs sandbox


## Element

For maintaining state, **with** side-effects.

    page =
        Page.element
            { title = title
            , init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

@docs element


## Component

For a full-blown page, that can view and update global state.

    page =
        Page.component
            { title = title
            , init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

@docs component


# Composing pages together

The rest of this module contains types and functions that
can be generated with the [cli companion tool](https://github.com/ryannhg/elm-spa/tree/master/cli)

If you're typing this stuff manually, you might need to know what
these are for!


## Layout

A page that is comprimised of smaller pages, that is
able to share a common layout (maybe a something like a sidebar!)

    page =
        Page.layout
            { map = Html.map
            , layout = Layout.view
            , pages =
                { init = init
                , update = update
                , bundle = bundle
                }
            }

@docs layout


## Recipe

Implementing the `init`, `update` and `bundle` functions is much easier
when you turn a `Page` type into `Recipe`.

A `Recipe` contains a record waiting for page specific data.

  - `init`: just needs a `route`

  - `upgrade` : just needs a `msg` and `model`

  - `bundle` (`view`/`subscriptions`) : just needs a `model`


### What's a "bundle"?

We can "bundle" the `view` and `subscriptions` functions together,
because they both only depend on the current `model`. That's why this
API exposes `bundle` instead of making you type this:

    -- BEFORE
    view model =
        case model_ of
            FooModel model ->
                foo.view model

            BarModel model ->
                bar.view model

            BazModel model ->
                baz.view model

    subscriptions model =
        case model_ of
            FooModel model ->
                foo.subscriptions model

            BarModel model ->
                bar.subscriptions model

            BazModel model ->
                baz.subscriptions model

    -- AFTER
    bundle model =
        case model_ of
            FooModel model ->
                foo.bundle model

            BarModel model ->
                bar.bundle model

            BazModel model ->
                baz.bundle model

(Woohoo, less case expressions to type out!)

@docs recipe


## Update helper

@docs keep

-}

import Internals.Page exposing (..)


type alias Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    Internals.Page.Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg


{-| Turns a page and some upgrade information into a recipe,
for use in a layout's `init`, `update`, and `bundle` functions!

    Page.recipe Homepage.page
        { toModel = HomepageModel
        , toMsg = HomepageMsg
        , map = Element.map -- ( if using elm-ui )
        }

-}
recipe :
    Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
    ->
        { toModel : pageModel -> layoutModel
        , toMsg : pageMsg -> layoutMsg
        , map : (pageMsg -> layoutMsg) -> uiPageMsg -> uiLayoutMsg
        }
    -> Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
recipe =
    Internals.Page.upgrade


{-| In the event that our `case` expression in `update` receives a `msg` that doesn't
match it's `model`, we use this function to keep the model as-is.

    update msg_ model_ =
        case ( msg_, model_ ) of
            ( FooMsg msg, FooModel model ) ->
                foo.update msg model

            ( BarMsg msg, BarModel model ) ->
                bar.update msg model

            ( BazMsg msg, BazModel model ) ->
                baz.update msg model

            _ ->
                Page.keep model_

-}
keep :
    layoutModel
    -> Update layoutModel layoutMsg globalModel globalMsg
keep model =
    always ( model, Cmd.none, Cmd.none )



-- STATIC


{-| Create an `static` page from a record. [Here's an example](https://github.com/ryannhg/elm-spa/examples/html/src/Pages/Index.elm)
-}
static :
    { title : String
    , view : uiPageMsg
    }
    -> Page pageRoute () Never uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
static page =
    Page
        (\{ toModel, toMsg, map } ->
            { init = \_ _ -> ( toModel (), Cmd.none, Cmd.none )
            , update = \_ model _ -> ( toModel model, Cmd.none, Cmd.none )
            , bundle =
                \_ context ->
                    { title = page.title
                    , view = page.view |> map toMsg |> context.map context.fromPageMsg
                    , subscriptions = Sub.none
                    }
            }
        )



-- SANDBOX


{-| Create an `sandbox` page from a record. [Here's an example](https://github.com/ryannhg/elm-spa/examples/html/src/Pages/Counter.elm)
-}
sandbox :
    { title : pageModel -> String
    , init : pageRoute -> pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> uiPageMsg
    }
    -> Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
sandbox page =
    Page
        (\{ toModel, toMsg, map } ->
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
        )



-- ELEMENT


{-| Create an `element` page from a record. [Here's an example](https://github.com/ryannhg/elm-spa/examples/html/src/Pages/Random.elm)
-}
element :
    { title : pageModel -> String
    , init : pageRoute -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> uiPageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }
    -> Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
element page =
    Page
        (\{ toModel, toMsg, map } ->
            { init =
                \pageRoute _ ->
                    page.init pageRoute
                        |> tuple toModel toMsg
            , update =
                \msg model _ ->
                    page.update msg model
                        |> tuple toModel toMsg
            , bundle =
                \model context ->
                    { title = page.title model
                    , view = page.view model |> map toMsg |> context.map context.fromPageMsg
                    , subscriptions = page.subscriptions model |> Sub.map (toMsg >> context.fromPageMsg)
                    }
            }
        )



-- COMPONENT


{-| Create an `component` page from a record. [Here's an example](https://github.com/ryannhg/elm-spa/examples/html/src/Pages/SignIn.elm)
-}
component :
    { title : globalModel -> pageModel -> String
    , init : globalModel -> pageRoute -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , update : globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , view : globalModel -> pageModel -> uiPageMsg
    , subscriptions : globalModel -> pageModel -> Sub pageMsg
    }
    -> Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
component page =
    Page
        (\{ toModel, toMsg, map } ->
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
        )



-- LAYOUT


{-| These are used by top-level files like `src/Generated/Pages.elm`
to compose together pages and layouts.

We'll get a better understanding of `init`, `update`, and `bundle` below!

    Page.layout
        { map = Html.map
        , layout = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }

-}
layout :
    { map : (pageMsg -> msg) -> uiPageMsg -> uiMsg
    , view :
        { page : uiMsg
        , global : globalModel
        }
        -> uiMsg
    , pages : Recipe pageRoute pageModel pageMsg pageModel pageMsg uiPageMsg globalModel globalMsg msg uiMsg
    }
    -> Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
layout options =
    Page
        (\{ toModel, toMsg } ->
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
                        bundle : { title : String, view : uiMsg, subscriptions : Sub msg }
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
                        options.view
                            { page = bundle.view
                            , global = context.global
                            }
                    , subscriptions = bundle.subscriptions
                    }
            }
        )



-- UTILS


tuple :
    (model -> bigModel)
    -> (msg -> bigMsg)
    -> ( model, Cmd msg )
    -> ( bigModel, Cmd bigMsg, Cmd a )
tuple toModel toMsg ( model, cmd ) =
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

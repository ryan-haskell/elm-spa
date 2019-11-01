module Application.Page exposing
    ( Page
    , Static, static
    , Sandbox, sandbox
    , Element, element
    , Component, component
    , Layout, layout
    , recipe, keep
    )

{-|


# Pages

@docs Page

Each page can be as simple or complex as you need:

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

@docs Static, static


## Sandbox

For maintaining state, without any side-effects.

    page =
        Page.sandbox
            { title = title
            , init = init
            , update = update
            , view = view
            }

@docs Sandbox, sandbox


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

@docs Element, element


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

@docs Component, component


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

@docs Layout, layout


## Recipes and helpers

Implementing the `init`, `update` and `bundle` functions is much easier
when you turn a `Page` type into `Recipe`.

A `Recipe` contains a record waiting for page specific data.

  - `init`: just needs a `route`

  - `upgrade` : just needs a `msg` and `model`

  - `bundle` (`view`/`subscriptions`) : just needs a `model`

(**Fun fact:** We're can determine `view` and `subscriptions` in the same `case` expression,
because they both only depend on the current `model`. That's why `bundle` exists!)

@docs recipe, keep

-}

import Internals.Page exposing (..)


{-| Page docs
-}
type alias Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg =
    Internals.Page.Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg


{-| Turns a page and some upgrade information into a recipe,
for use in a layout's `init`, `update, and`bundle\` functions!

    Page.recipe Homepage.page
        { toModel = HomepageModel
        , toMsg = HomepageMsg
        , map = Element.map -- ( if using elm-ui )
        }

-}
recipe :
    Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
    ->
        { toModel : pageModel -> layoutModel
        , toMsg : pageMsg -> layoutMsg
        , map : (pageMsg -> layoutMsg) -> htmlPageMsg -> htmlLayoutMsg
        }
    -> Internals.Page.Recipe pageRoute pageModel pageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
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
keep : layoutModel -> Update layoutModel layoutMsg globalModel globalMsg
keep model =
    always ( model, Cmd.none, Cmd.none )



-- STATIC


{-|

    title : String

    view : Html msg

-}
type alias Static htmlPageMsg =
    { title : String
    , view : htmlPageMsg
    }


{-| Create an `static` page from a record. [Here's an example](https://github.com/ryannhg/elm-spa/examples/html/src/Pages/Index.elm)
-}
static :
    Static htmlPageMsg
    -> Page pageRoute () Never htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
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


{-|

    title : Model -> String

    init : Route -> Model

    update : Msg -> Model -> Model

    view : Model -> Html Msg

-}
type alias Sandbox pageRoute pageModel pageMsg htmlPageMsg =
    { title : pageModel -> String
    , init : pageRoute -> pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> htmlPageMsg
    }


{-| Create an `sandbox` page from a record. [Here's an example](https://github.com/ryannhg/elm-spa/examples/html/src/Pages/Counter.elm)
-}
sandbox :
    Sandbox pageRoute pageModel pageMsg htmlPageMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
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


{-|

    title : Model -> String

    init : Route -> ( Model, Cmd Msg )

    update : Msg -> Model -> ( Model, Cmd Msg )

    view : Model -> Html Msg

    subscriptions : Model -> Sub Msg

-}
type alias Element pageRoute pageModel pageMsg htmlPageMsg =
    { title : pageModel -> String
    , init : pageRoute -> ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> htmlPageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


{-| Create an `element` page from a record. [Here's an example](https://github.com/ryannhg/elm-spa/examples/html/src/Pages/Random.elm)
-}
element :
    Element pageRoute pageModel pageMsg htmlPageMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
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


{-|

    title : Global.Model -> Model -> String

    init : Global.Model -> Route -> ( Model, Cmd Msg, Cmd Global.Msg )

    update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )

    view : Global.Model -> Model -> Html Msg

    subscriptions : Global.Model -> Model -> Sub Msg

-}
type alias Component pageRoute pageModel pageMsg globalModel globalMsg htmlPageMsg =
    { title : globalModel -> pageModel -> String
    , init : globalModel -> pageRoute -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , update : globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , view : globalModel -> pageModel -> htmlPageMsg
    , subscriptions : globalModel -> pageModel -> Sub pageMsg
    }


{-|

    Page.component
        { title = title
        , init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

-}
component :
    Component pageRoute pageModel pageMsg globalModel globalMsg htmlPageMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
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

-}
type alias Layout pageRoute pageModel pageMsg globalModel globalMsg msg htmlPageMsg htmlMsg =
    { map : (pageMsg -> msg) -> htmlPageMsg -> htmlMsg
    , view :
        { page : htmlMsg
        , global : globalModel
        }
        -> htmlMsg
    , pages : Recipe pageRoute pageModel pageMsg pageModel pageMsg htmlPageMsg globalModel globalMsg msg htmlMsg
    }


{-|

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
    Layout pageRoute pageModel pageMsg globalModel globalMsg msg htmlPageMsg htmlMsg
    -> Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
layout options =
    Page
        (\{ toModel, toMsg, map } ->
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

module Spa.Page exposing
    ( static
    , sandbox
    , element
    , component, send
    , layout
    , recipe
    , keep
    )

{-| Each page can be as simple or complex as you need:

1.  [Static](#static) - a page without state

2.  [Sandbox](#sandbox) - a page without side-effects

3.  [Element](#element) - a page _with_ side-effects

4.  [Component](#component) - a page that can change the global state


## what's that `always` for?

You may notice the examples below use `always`. This is to **opt-out** each
function from reading the global model.

If you need access to `Global.Model` in your `title`, `init`, `update`, `view`, or
`subscriptions` functions, just remove the always.

**It is recommended to include this to keep your pages as simple as possible!**


# static

@docs static


# sandbox

@docs sandbox


# element

@docs element


# component

@docs component, send


# composing pages together

The rest of this module contains types and functions that
can be generated with the [cli companion tool](https://github.com/ryannhg/elm-spa/tree/master/cli)

If you're typing this stuff manually, you might need to know what
these are for!


## layout

@docs layout


## recipe

@docs recipe


## what's a "bundle"?

We can "bundle" the `view` and `subscriptions` functions together,
because they both only need the current `model`.

So _instead_ of typing out these:

    view bigModel =
        case bigModel of
            FooModel model ->
                foo.view model

            BarModel model ->
                bar.view model

            BazModel model ->
                baz.view model

    subscriptions bigModel =
        case bigModel of
            FooModel model ->
                foo.subscriptions model

            BarModel model ->
                bar.subscriptions model

            BazModel model ->
                baz.subscriptions model

You only need **one** case expression: (woohoo, less boilerplate!)

    bundle bigModel =
        case bigModel of
            FooModel model ->
                foo.bundle model

            BarModel model ->
                bar.bundle model

            BazModel model ->
                baz.bundle model


## update helpers

@docs keep

-}

import Internals.Page exposing (..)
import Internals.Pattern as Pattern exposing (Pattern)
import Internals.Transition as Transition exposing (Transition)
import Internals.Utils as Utils


type alias PageContext route globalModel =
    Internals.Page.PageContext route globalModel


type alias Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Internals.Page.Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-| Implementing the `init`, `update` and `bundle` functions is much easier
when you turn a `Page` type into `Recipe`.

A `Recipe` contains a record waiting for page specific data.

  - `init`: just needs a `route`

  - `upgrade` : just needs a `msg` and `model`

  - `bundle` (`view`/`subscriptions`) : just needs a `model`

        import Utils.Spa as Spa

        recipes : Recipes msg
        recipes =
            { top =
                Spa.recipe
                    { page = Top.page
                    , toModel = TopModel
                    , toMsg = TopMsg
                    }
            , counter =
                Spa.recipe
                    { page = Counter.page
                    , toModel = CounterModel
                    , toMsg = CounterMsg
                    }

            -- ...
            }

-}
recipe :
    ((pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg)
    -> Upgrade route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    -> Recipe route pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
recipe =
    Internals.Page.upgrade


{-| In the event that our `case` expression in `update` receives a `msg` that doesn't
match up with it's `model`, we use `keep` to leave the page as-is.

    update : Msg -> Model -> Spa.Update Model Msg
    update bigMsg bigModel =
        case ( bigMsg, bigModel ) of
            ( TopMsg msg, TopModel model ) ->
                top.update msg model

            ( CounterMsg msg, CounterModel model ) ->
                counter.update msg model

            ( NotFoundMsg msg, NotFoundModel model ) ->
                notFound.update msg model

            _ ->
                Page.keep bigModel

-}
keep :
    layoutModel
    -> Update route layoutModel layoutMsg globalModel globalMsg
keep model =
    always ( model, Cmd.none, Cmd.none )


{-|


## an example

    page =
        Page.static
            { title = always title
            , view = always view
            }

    title : String
    title =
        "Example"

    view : Html Never
    view =
        h1 [ class "title" ] [ text "Example" ]

-}
static :
    { title : { global : globalModel } -> String
    , view : PageContext route globalModel -> ui_pageMsg
    }
    -> Page route pageParams () Never ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
static page =
    Page
        (\{ toModel, toMsg, map } ->
            { init = \_ _ -> ( toModel (), Cmd.none, Cmd.none )
            , update = \_ model _ -> ( toModel model, Cmd.none, Cmd.none )
            , bundle =
                \_ private context ->
                    { title =
                        page.title
                            { global = context.global
                            }
                    , view =
                        page.view
                            context
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions = Sub.none
                    }
            }
        )



-- SANDBOX


{-|


## an example

    page =
        Page.sandbox
            { title = always title
            , init = always init
            , update = always update
            , view = always view
            }

    title : String
    title =
        "Counter"

    type alias Model =
        Int

    init : Model
    init =
        0

    type Msg
        = Increment
        | Decrement

    update : Msg -> Model -> Model
    update msg model =
        case msg of
            Increment ->
                model + 1

            Decrement ->
                model - 1

    view : Model -> Html Msg
    view model =
        div []
            [ button [ Events.onClick Increment ] [ text "+" ]
            , text (String.fromInt model)
            , button [ Events.onClick Decrement ] [ text "-" ]
            ]

-}
sandbox :
    { title : { global : globalModel, model : pageModel } -> String
    , init : PageContext route globalModel -> pageParams -> pageModel
    , update : PageContext route globalModel -> pageMsg -> pageModel -> pageModel
    , view : PageContext route globalModel -> pageModel -> ui_pageMsg
    }
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
sandbox page =
    Page
        (\{ toModel, toMsg, map } ->
            { init =
                \pageParams context ->
                    ( toModel (page.init context pageParams)
                    , Cmd.none
                    , Cmd.none
                    )
            , update =
                \msg model context ->
                    ( page.update context msg model
                        |> toModel
                    , Cmd.none
                    , Cmd.none
                    )
            , bundle =
                \model private context ->
                    { title =
                        page.title
                            { global = context.global
                            , model = model
                            }
                    , view =
                        page.view context model
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions = Sub.none
                    }
            }
        )



-- ELEMENT


{-|


## an example

    page =
        Page.element
            { title = always title
            , init = always init
            , update = always update
            , subscriptions = always subscriptions
            , view = always view
            }

    title : String
    title =
        "Cat Gifs"

    init : ( Model, Cmd.none )
    init =
        -- ...

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        -- ...

    subscriptions : Model -> Sub Msg
    subscriptions model =
        -- ...

    view : Model -> Html Msg
    view model =
        -- ...

-}
element :
    { title : { global : globalModel, model : pageModel } -> String
    , init : PageContext route globalModel -> pageParams -> ( pageModel, Cmd pageMsg )
    , update : PageContext route globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : PageContext route globalModel -> pageModel -> ui_pageMsg
    , subscriptions : PageContext route globalModel -> pageModel -> Sub pageMsg
    }
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
element page =
    Page
        (\{ toModel, toMsg, map } ->
            { init =
                \pageParams context ->
                    page.init context pageParams
                        |> tuple toModel toMsg
            , update =
                \msg model context ->
                    page.update context msg model
                        |> tuple toModel toMsg
            , bundle =
                \model private context ->
                    { title =
                        page.title
                            { global = context.global
                            , model = model
                            }
                    , view =
                        page.view context model
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions =
                        page.subscriptions context model
                            |> Sub.map (toMsg >> private.fromPageMsg)
                    }
            }
        )



-- COMPONENT


{-|


## an example

    page =
        Page.component
            { title = always title
            , init = always init
            , update = always update
            , subscriptions = always subscriptions
            -- no always, so `view` gets `Global.Model`
            , view = view
            }

    title : String
    title =
        "Sign in"

    init : Params.SignIn -> ( Model, Cmd Msg, Cmd Global.Msg )
    init params =
        -- ...

    update : Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    update msg model =
        -- ...

    subscriptions : Model -> Sub Msg
    subscriptions model =
        -- ...

    view : Global.Model -> Model -> Html Msg
    view global model =
        case global.user of
            SignedIn _ -> viewSignOutForm
            SignedOut -> viewSignInForm

-}
component :
    { title : { global : globalModel, model : pageModel } -> String
    , init : PageContext route globalModel -> pageParams -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , update : PageContext route globalModel -> pageMsg -> pageModel -> ( pageModel, Cmd pageMsg, Cmd globalMsg )
    , view : PageContext route globalModel -> pageModel -> ui_pageMsg
    , subscriptions : PageContext route globalModel -> pageModel -> Sub pageMsg
    }
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
component page =
    Page
        (\{ toModel, toMsg, map } ->
            { init =
                \pageParams context ->
                    page.init context pageParams
                        |> truple toModel toMsg
            , update =
                \msg model context ->
                    page.update context msg model
                        |> truple toModel toMsg
            , bundle =
                \model private context ->
                    { title =
                        page.title
                            { global = context.global
                            , model = model
                            }
                    , view =
                        page.view context model
                            |> map toMsg
                            |> private.map private.fromPageMsg
                    , subscriptions =
                        page.subscriptions context model
                            |> Sub.map (toMsg >> private.fromPageMsg)
                    }
            }
        )


{-| Useful for sending `Global.Msg` from a component.

    init : Params.SignIn -> ( Model, Cmd Msg, Cmd Global.Msg )
    init params =
        ( model
        , Cmd.none
        , Page.send (Global.NavigateTo routes.dashboard)
        )

-}
send : msg -> Cmd msg
send =
    Utils.send



-- LAYOUT


{-| In practice, we wrap `layout` in `Utils/Spa.elm` so we only have to provide `Html.map` or `Element.map` once)

    import Utils.Spa as Spa

    page =
        Spa.layout
            { layout = Layout.view
            , pages =
                { init = init
                , update = update
                , bundle = bundle
                }
            }

-}
layout :
    ((pageMsg -> msg) -> ui_pageMsg -> ui_msg)
    -> Layout route pageParams pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg
    -> Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
layout map options =
    Page
        (\{ toModel, toMsg } ->
            { init =
                \pageParams global ->
                    options.recipe.init pageParams global
                        |> truple toModel toMsg
            , update =
                \msg model global ->
                    options.recipe.update msg model global
                        |> truple toModel toMsg
            , bundle =
                \model private context ->
                    let
                        viewLayout page =
                            options.view
                                { page = page
                                , global = context.global
                                , fromGlobalMsg = private.fromGlobalMsg
                                , route = context.route
                                }

                        myLayoutsVisibility : Transition.Visibility
                        myLayoutsVisibility =
                            if private.transitioningPattern == options.pattern then
                                private.visibility

                            else
                                Transition.visible

                        bundle : { title : String, view : ui_msg, subscriptions : Sub msg }
                        bundle =
                            options.recipe.bundle
                                model
                                { fromGlobalMsg = private.fromGlobalMsg
                                , fromPageMsg = toMsg >> private.fromPageMsg
                                , map = map
                                , transitioningPattern = private.transitioningPattern
                                , visibility = private.visibility
                                }
                                context
                    in
                    { title = bundle.title
                    , view =
                        Transition.view
                            options.transition
                            myLayoutsVisibility
                            { layout = viewLayout
                            , page = bundle.view
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

module App.Types exposing
    ( Page, Recipe
    , Init, Update, Bundle
    )

{-|


## Types so spooky, they got their own module! 👻

This module is all about exposing the types that `ryannhg/elm-app` uses
under the hood.

Because so much of your app is defined outside of this package, we see
a **lot of generic types**.


### Don't be spooked!

In practice, we usually handle this with a `Utils/Page.elm` file that
creates less generic `type alias` for use in your app!

    module Utils.Spa exposing
        ( Bundle
        , Init
        , Page
        , Recipe
        , Update
        , layout
        , recipe
        )

    import App.Page
    import App.Types
    import Element exposing (Element)
    import Global

    type alias Page flags model msg layoutModel layoutMsg appMsg =
        App.Types.Page flags model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)

    type alias Recipe flags model msg layoutModel layoutMsg appMsg =
        App.Types.Recipe flags model msg layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)

    type alias Init model msg =
        App.Types.Init model msg Global.Model Global.Msg

    type alias Update model msg =
        App.Types.Update model msg Global.Model Global.Msg

    type alias Bundle msg appMsg =
        App.Types.Bundle msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)

    layout config =
        App.Page.layout
            { map = Element.map
            , view = config.view
            , recipe = config.recipe
            }

    recipe config =
        App.Page.recipe
            { map = Element.map
            , page = config.page
            , toModel = config.toModel
            , toMsg = config.toMsg
            }

@docs Page, Recipe

@docs Init, Update, Bundle

-}

import Internals.Page as Page


{-| This type alias should be used in all `src/Pages` files.

    module Pages.Example exposing
        ( page
        , -- ...
        )

    import Utils.Spa as Spa

    page : Spa.Page Params.Example Model Msg model msg appMsg
    page =
        App.Page.static

    -- ...

-}
type alias Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    Page.Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg


{-| Recipe
-}
type alias Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    Page.Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg


{-| Init
-}
type alias Init layoutModel layoutMsg globalModel globalMsg =
    Page.Init layoutModel layoutMsg globalModel globalMsg


{-| Update
-}
type alias Update layoutModel layoutMsg globalModel globalMsg =
    Page.Update layoutModel layoutMsg globalModel globalMsg


{-| Bundle
-}
type alias Bundle layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    Page.Bundle layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg

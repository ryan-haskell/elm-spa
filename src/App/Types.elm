module App.Types exposing
    ( Page
    , Recipe
    , Init
    , Update
    , Bundle
    )

{-|


## types so spooky, they got their own module! 👻

This module is all about exposing the types that `ryannhg/elm-app` uses
under the hood.

At a glance, there are a **lot of generic types**.

In practice, we can handle this with a single
[`Utils/Spa.elm`](https://github.com/ryannhg/elm-spa/blob/master/example/src/Utils/Spa.elm) file that
makes your types easier to understand!

`elm-spa init` generates that file for you, but I've added examples below if you're
doing things by hand.


# page

@docs Page


# recipe

@docs Recipe


# init

@docs Init


# update

@docs Update


# bundle

@docs Bundle

-}

import Internals.Page as Page


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import App.Types
    import Element exposing (Element)

    type alias Page params model msg layoutModel layoutMsg appMsg =
        App.Types.Page params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)

    -- if using elm/html

    import App.Types
    import Html exposing (Html)

    type alias Page params model msg layoutModel layoutMsg appMsg =
        App.Types.Page params model msg (Html msg) layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`src/Pages/Example.elm`**

    import Utils.Spa as Spa

    page : Spa.Page Params.Example Model Msg model msg appMsg
    page =
        App.Page.static { ... }

-}
type alias Page params pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Page.Page params pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import App.Types
    import Element exposing (Element)

    type alias Recipe params model msg layoutModel layoutMsg appMsg =
        App.Types.Recipe params model msg layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)

    -- if using elm/html

    import App.Types
    import Html exposing (Html)

    type alias Recipe params model msg layoutModel layoutMsg appMsg =
        App.Types.Recipe params model msg layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    type alias Recipes appMsg =
        { top : Spa.Recipe Params.Top Top.Model Top.Msg Model Msg appMsg
        , example : Spa.Recipe Params.Example Example.Model Example.Msg Model Msg appMsg
        , notFound : Spa.Recipe Params.NotFound NotFound.Model NotFound.Msg Model Msg appMsg
        }

-}
type alias Recipe params pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Page.Recipe params pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    type alias Init model msg =
        App.Types.Init model msg Global.Model Global.Msg


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    init : Route -> Spa.Init Model Msg
    init route_ =
        case route_ of
            -- ...

-}
type alias Init layoutModel layoutMsg globalModel globalMsg =
    Page.Init layoutModel layoutMsg globalModel globalMsg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    type alias Update model msg =
        App.Types.Update model msg Global.Model Global.Msg


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    update : Msg -> Model -> Spa.Update Model Msg
    update msg_ model_ =
        case ( msg_, model_ ) of
            -- ...

-}
type alias Update layoutModel layoutMsg globalModel globalMsg =
    Page.Update layoutModel layoutMsg globalModel globalMsg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import App.Types
    import Element exposing (Element)

    type alias Bundle msg appMsg =
        App.Types.Bundle msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)

    -- if using elm/html

    import App.Types
    import Html exposing (Html)

    type alias Bundle msg appMsg =
        App.Types.Bundle msg (Html msg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    bundle : Model -> Spa.Bundle Msg msg
    bundle model_ =
        case model_ of
            -- ...

-}
type alias Bundle layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Page.Bundle layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg

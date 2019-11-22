module Spa.Types exposing
    ( Page
    , Recipe
    , Init
    , Update
    , Bundle
    , Layout, Upgrade
    , Transitions
    , LayoutContext, PageContext
    )

{-|


## types so spooky, they got their own module!

This module is all about exposing the types that `ryannhg/elm-spa` uses
under the hood.

You might notice that there are a **lot of generic types**.

In practice, we can avoid the messy types with a single
[`Utils/Spa.elm`](https://github.com/ryannhg/elm-spa/blob/master/example/src/Utils/Spa.elm) file that
makes your types easier to understand!

`elm-spa init` will generate that file for you, but I've added examples below if you're
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


# layouts and recipes

@docs Layout, Upgrade


# transitions

@docs Transitions


# context

@docs LayoutContext, PageContext

-}

import Dict exposing (Dict)
import Internals.Page as Page
import Internals.Path exposing (Path)
import Internals.Transition exposing (Transition)


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import Spa.Types
    import Element exposing (Element)

    type alias Page params model msg layoutModel layoutMsg appMsg =
        Spa.Types.Page Route params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)

    -- if using elm/html

    import Spa.Types
    import Html exposing (Html)

    type alias Page params model msg layoutModel layoutMsg appMsg =
        Spa.Types.Page Route params model msg (Html msg) layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`src/Pages/Example.elm`**

    import Utils.Spa as Spa

    page : Spa.Page Params.Example Model Msg model msg appMsg
    page =
        Spa.Page.static { ... }

-}
type alias Page route params pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Page.Page route params pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import Spa.Types
    import Element exposing (Element)

    type alias Recipe params model msg layoutModel layoutMsg appMsg =
        Spa.Types.Recipe Route params model msg layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)

    -- if using elm/html

    import Spa.Types
    import Html exposing (Html)

    type alias Recipe params model msg layoutModel layoutMsg appMsg =
        Spa.Types.Recipe Route params model msg layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    type alias Recipes appMsg =
        { top : Spa.Recipe Params.Top Top.Model Top.Msg Model Msg appMsg
        , example : Spa.Recipe Params.Example Example.Model Example.Msg Model Msg appMsg
        , notFound : Spa.Recipe Params.NotFound NotFound.Model NotFound.Msg Model Msg appMsg
        }

-}
type alias Recipe route params pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Page.Recipe route params pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    type alias Init model msg =
        Spa.Types.Init Route model msg Global.Model Global.Msg


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    init : Route -> Spa.Init Model Msg
    init route_ =
        case route_ of
            -- ...

-}
type alias Init route layoutModel layoutMsg globalModel globalMsg =
    Page.Init route layoutModel layoutMsg globalModel globalMsg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    type alias Update model msg =
        Spa.Types.Update Route model msg Global.Model Global.Msg


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    update : Msg -> Model -> Spa.Update Model Msg
    update msg_ model_ =
        case ( msg_, model_ ) of
            -- ...

-}
type alias Update route layoutModel layoutMsg globalModel globalMsg =
    Page.Update route layoutModel layoutMsg globalModel globalMsg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import Spa.Types
    import Element exposing (Element)

    type alias Bundle msg appMsg =
        Spa.Types.Bundle Route msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)

    -- if using elm/html

    import Spa.Types
    import Html exposing (Html)

    type alias Bundle msg appMsg =
        Spa.Types.Bundle Route msg (Html msg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`.elm-spa/Generated/Pages.elm`**

    import Utils.Spa as Spa

    bundle : Model -> Spa.Bundle Msg msg
    bundle model_ =
        case model_ of
            -- ...

-}
type alias Bundle route layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Page.Bundle route layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import Spa.Types
    import Element exposing (Element)

    type alias Layout params model msg appMsg =
        Spa.Types.Layout Route params model msg (Element msg) Global.Model Global.Msg appMsg (Element appMsg)


    -- if using elm/html

    import Spa.Types
    import Html exposing (Html)

    type alias Layout params model msg appMsg =
        Spa.Types.Layout Route params model msg (Html msg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`src/Utils/Spa.elm`**

    layout :
        Layout params model msg appMsg
        -> Page params model msg layoutModel layoutMsg appMsg
    layout =
        Spa.Page.layout Element.map

-}
type alias Layout route pageParams pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg =
    Page.Layout route pageParams pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg


{-| Describes how to transition between layouts and pages.

    transitions : Transitions (Html msg)
    transitions =
        { layout = Transition.none -- page loads instantly
        , page = Transition.fadeHtml 300
        , pages = []
        }

-}
type alias Transitions ui_msg =
    { layout : Transition ui_msg
    , page : Transition ui_msg
    , pages :
        List
            { path : Path
            , transition : Transition ui_msg
            }
    }


{-| This is what your `src/Pages/*.elm` files can access!


## creating your alias

**`src/Utils/Spa.elm`**

    type alias PageContext =
        Spa.Types.PageContext Route Global.Model


## using your alias

**`src/Pages/Top.elm`**

    import Utils.Spa as Spa

    page =
        Page.static
            { title = always "Homepage"
            , view = view -- leaving off always here!
            }

    view : PageContext -> Html Msg
    view context =
        case context.global.user of
            SignedIn user ->
                viewUser user

            SignedOut ->
                text "Who dis?"

-}
type alias PageContext route globalModel =
    { global : globalModel
    , route : route
    , queryParameters : Dict String String
    }


{-| This is what your `src/Layouts/*.elm` files can access!


## creating your alias

**`src/Utils/Spa.elm`**

    type alias LayoutContext msg =
        Spa.Types.LayoutContext Route msg (Element msg) Global.Model Global.Msg


## using your alias

**`src/Layout.elm`**

    import Utils.Spa as Spa

    view : Spa.LayoutContext msg -> Html msg
    view { page, fromGlobalMsg, global } =
        div [ class "app" ]
            [ Html.map fromGlobalMsg (viewNavbar global)
            , page
            , viewFooter
            ]

    viewNavbar : Global.Model -> Html Global.Msg
    viewNavbar =
        -- ...

    viewFooter : Html msg
    viewFooter =
        -- ...

-}
type alias LayoutContext route msg ui_msg globalModel globalMsg =
    { page : ui_msg
    , route : route
    , global : globalModel
    , fromGlobalMsg : globalMsg -> msg
    }


{-|


## creating your alias

**`src/Utils/Spa.elm`**

    -- if using mdgriffith/elm-ui

    import Spa.Types
    import Element exposing (Element)

    type alias Upgrade params model msg layoutModel layoutMsg appMsg =
        Spa.Types.Upgrade Route params model msg (Element msg) layoutModel layoutMsg (Element layoutMsg) Global.Model Global.Msg appMsg (Element appMsg)

    -- if using elm/html

    import Spa.Types
    import Html exposing (Html)

    type alias Upgrade params model msg layoutModel layoutMsg appMsg =
        Spa.Types.Upgrade Route params model msg (Html msg) layoutModel layoutMsg (Html layoutMsg) Global.Model Global.Msg appMsg (Html appMsg)


## using your alias

**`src/Utils/Spa.elm`**

    recipe :
        Upgrade params model msg layoutModel layoutMsg appMsg
        -> Recipe params model msg layoutModel layoutMsg appMsg
    recipe =
        Spa.Page.recipe Element.map

-}
type alias Upgrade route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    Page.Upgrade route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg

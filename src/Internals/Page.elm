module Internals.Page exposing
    ( Bundle
    , Context
    , Init
    , Layout
    , Page(..)
    , Recipe
    , Update
    , Upgrade
    , upgrade
    )

import Internals.Pattern exposing (Pattern)
import Internals.Transition as Transition exposing (Transition)


type Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    = Page (Page_ route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg)


type alias Page_ route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    , map : (pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg
    }
    -> Recipe route pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


type alias Recipe route pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { init : pageParams -> Init layoutModel layoutMsg globalModel globalMsg
    , update : pageMsg -> pageModel -> Update layoutModel layoutMsg globalModel globalMsg
    , bundle : pageModel -> Bundle route layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    }


type alias Upgrade route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { page : Page route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    , toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    }


upgrade :
    ((pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg)
    -> Upgrade route pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    -> Recipe route pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
upgrade map config =
    let
        (Page page) =
            config.page
    in
    page
        { toModel = config.toModel
        , toMsg = config.toMsg
        , map = map
        }


type alias Init layoutModel layoutMsg globalModel globalMsg =
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


type alias Update layoutModel layoutMsg globalModel globalMsg =
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


type alias Bundle route layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { global : globalModel
    , fromGlobalMsg : globalMsg -> msg
    , fromPageMsg : layoutMsg -> msg
    , map : (layoutMsg -> msg) -> ui_layoutMsg -> ui_msg
    , route : route
    , visibility : Transition.Visibility
    , transitioningPattern : Pattern
    }
    ->
        { title : String
        , view : ui_msg
        , subscriptions : Sub msg
        }


type alias Context route msg ui_msg globalModel globalMsg =
    { page : ui_msg
    , route : route
    , global : globalModel
    , toMsg : globalMsg -> msg
    }


type alias Layout route pageParams pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg =
    { pattern : Pattern
    , transition : Transition ui_msg
    , view : Context route msg ui_msg globalModel globalMsg -> ui_msg
    , recipe : Recipe route pageParams pageModel pageMsg pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg
    }

module Internals.Page exposing
    ( Bundle
    , Init
    , Page(..)
    , Recipe
    , Update
    , upgrade
    )

{-| Page docs
-}


type Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
    = Page (Page_ pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg)


type alias Page_ pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    { toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    , map : (pageMsg -> layoutMsg) -> uiPageMsg -> uiLayoutMsg
    }
    -> Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg


{-| Recipe docs
-}
type alias Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    { init : pageRoute -> Init layoutModel layoutMsg globalModel globalMsg
    , update : pageMsg -> pageModel -> Update layoutModel layoutMsg globalModel globalMsg
    , bundle : pageModel -> Bundle layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
    }


upgrade :
    Page pageRoute pageModel pageMsg uiPageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
    ->
        { toModel : pageModel -> layoutModel
        , toMsg : pageMsg -> layoutMsg
        , map : (pageMsg -> layoutMsg) -> uiPageMsg -> uiLayoutMsg
        }
    -> Recipe pageRoute pageModel pageMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg
upgrade (Page fn) data =
    fn data


{-| Init docs
-}
type alias Init layoutModel layoutMsg globalModel globalMsg =
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


{-| Update docs
-}
type alias Update layoutModel layoutMsg globalModel globalMsg =
    { global : globalModel }
    -> ( layoutModel, Cmd layoutMsg, Cmd globalMsg )


{-| Bundle docs
-}
type alias Bundle layoutMsg uiLayoutMsg globalModel globalMsg msg uiMsg =
    { global : globalModel
    , fromGlobalMsg : globalMsg -> msg
    , fromPageMsg : layoutMsg -> msg
    , map : (layoutMsg -> msg) -> uiLayoutMsg -> uiMsg
    }
    ->
        { title : String
        , view : uiMsg
        , subscriptions : Sub msg
        }

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


type Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
    = Page (Page_ pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg)


type alias Page_ pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg =
    { toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    , map : (pageMsg -> layoutMsg) -> htmlPageMsg -> htmlLayoutMsg
    }
    -> Recipe pageRoute pageModel pageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg


{-| Recipe docs
-}
type alias Recipe pageRoute pageModel pageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg =
    { init : pageRoute -> Init layoutModel layoutMsg globalModel globalMsg
    , update : pageMsg -> pageModel -> Update layoutModel layoutMsg globalModel globalMsg
    , bundle : pageModel -> Bundle layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
    }


upgrade :
    Page pageRoute pageModel pageMsg htmlPageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
    ->
        { toModel : pageModel -> layoutModel
        , toMsg : pageMsg -> layoutMsg
        , map : (pageMsg -> layoutMsg) -> htmlPageMsg -> htmlLayoutMsg
        }
    -> Recipe pageRoute pageModel pageMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg msg htmlMsg
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

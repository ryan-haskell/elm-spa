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


type Page pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    = Page (Page_ pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg)


type alias Page_ pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    , map : (pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg
    }
    -> Recipe pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


{-| Recipe docs
-}
type alias Recipe pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { init : pageParams -> Init layoutModel layoutMsg globalModel globalMsg
    , update : pageMsg -> pageModel -> Update layoutModel layoutMsg globalModel globalMsg
    , bundle : pageModel -> Bundle layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    }


upgrade :
    { page : Page pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    , toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    , map : (pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg
    }
    -> Recipe pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
upgrade config =
    let
        (Page page) =
            config.page
    in
    page
        { toModel = config.toModel
        , toMsg = config.toMsg
        , map = config.map
        }


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
type alias Bundle layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { global : globalModel
    , fromGlobalMsg : globalMsg -> msg
    , fromPageMsg : layoutMsg -> msg
    , map : (layoutMsg -> msg) -> ui_layoutMsg -> ui_msg
    }
    ->
        { title : String
        , view : ui_msg
        , subscriptions : Sub msg
        }

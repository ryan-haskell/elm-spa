module Internals.Page exposing
    ( Bundle
    , Init
    , Layout
    , Page(..)
    , Recipe
    , Update
    , Upgrade
    , upgrade
    )


type Page pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    = Page (Page_ pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg)


type alias Page_ pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    , map : (pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg
    }
    -> Recipe pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg


type alias Recipe pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { init : pageParams -> Init layoutModel layoutMsg globalModel globalMsg
    , update : pageMsg -> pageModel -> Update layoutModel layoutMsg globalModel globalMsg
    , bundle : pageModel -> Bundle layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    }


type alias Upgrade pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg =
    { page : Page pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    , toModel : pageModel -> layoutModel
    , toMsg : pageMsg -> layoutMsg
    }


upgrade :
    ((pageMsg -> layoutMsg) -> ui_pageMsg -> ui_layoutMsg)
    -> Upgrade pageParams pageModel pageMsg ui_pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
    -> Recipe pageParams pageModel pageMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg msg ui_msg
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


type alias Layout pageParams pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg =
    { view :
        { page : ui_msg
        , global : globalModel
        , toMsg : globalMsg -> msg
        }
        -> ui_msg
    , recipe : Recipe pageParams pageModel pageMsg pageModel pageMsg ui_pageMsg globalModel globalMsg msg ui_msg
    }

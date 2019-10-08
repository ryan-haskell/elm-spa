module Internals.Page exposing
    ( Page
    , element
    , init
    , page
    , sandbox
    , static
    , subscriptions
    , title
    , toModel
    , toMsg
    , update
    , view
    )

import Html exposing (Html)
import Internals.Context exposing (Context)


type Page route flags contextModel contextMsg model msg appModel appMsg
    = Page (Page_ route flags contextModel contextMsg model msg appModel appMsg)


type alias Page_ route flags contextModel contextMsg model msg appModel appMsg =
    { title : Context flags route contextModel -> model -> String
    , init : Context flags route contextModel -> ( model, Cmd msg, Cmd contextMsg )
    , update : Context flags route contextModel -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : Context flags route contextModel -> model -> Sub msg
    , view : Context flags route contextModel -> model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }



-- CONSTRUCTORS


static :
    { title : String
    , view : Html Never
    , toModel : () -> appModel
    }
    -> Page route flags contextModel contextMsg () Never appModel appMsg
static config =
    Page
        { title = \c m -> config.title
        , init = \c -> ( (), Cmd.none, Cmd.none )
        , update = \c m model -> ( model, Cmd.none, Cmd.none )
        , subscriptions = \c m -> Sub.none
        , view = \c m -> Html.map never config.view
        , toMsg = never
        , toModel = config.toModel
        }


sandbox :
    { title : model -> String
    , init : model
    , update : msg -> model -> model
    , view : model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg
sandbox config =
    Page
        { title = \c model -> config.title model
        , init = \c -> ( config.init, Cmd.none, Cmd.none )
        , update = \c msg model -> ( config.update msg model, Cmd.none, Cmd.none )
        , subscriptions = \c m -> Sub.none
        , view = \c model -> config.view model
        , toMsg = config.toMsg
        , toModel = config.toModel
        }


element :
    { title : model -> String
    , init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg
element config =
    let
        appendCmd ( model, cmd ) =
            ( model, cmd, Cmd.none )
    in
    Page
        { title = \c model -> config.title model
        , init = \c -> config.init c.flags |> appendCmd
        , update = \c msg model -> config.update msg model |> appendCmd
        , subscriptions = \c model -> config.subscriptions model
        , view = \c model -> config.view model
        , toMsg = config.toMsg
        , toModel = config.toModel
        }


page :
    { title : Context flags route contextModel -> model -> String
    , init : Context flags route contextModel -> ( model, Cmd msg, Cmd contextMsg )
    , update : Context flags route contextModel -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : Context flags route contextModel -> model -> Sub msg
    , view : Context flags route contextModel -> model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg
page config =
    let
        appendCmd ( model, cmd ) =
            ( model, cmd, Cmd.none )
    in
    Page
        { title = config.title
        , init = config.init
        , update = config.update
        , subscriptions = \c model -> config.subscriptions c model
        , view = \c model -> config.view c model
        , toMsg = config.toMsg
        , toModel = config.toModel
        }



-- ACCESSORS


init :
    Page route flags contextModel contextMsg model msg appModel appMsg
    -> Context flags route contextModel
    -> ( model, Cmd msg, Cmd contextMsg )
init (Page page_) =
    page_.init


update :
    Page route flags contextModel contextMsg model msg appModel appMsg
    -> Context flags route contextModel
    -> msg
    -> model
    -> ( model, Cmd msg, Cmd contextMsg )
update (Page page_) =
    page_.update


title :
    Page route flags contextModel contextMsg model msg appModel appMsg
    -> Context flags route contextModel
    -> model
    -> String
title (Page page_) =
    page_.title


view :
    Page route flags contextModel contextMsg model msg appModel appMsg
    -> Context flags route contextModel
    -> model
    -> Html msg
view (Page page_) =
    page_.view


subscriptions :
    Page route flags contextModel contextMsg model msg appModel appMsg
    -> Context flags route contextModel
    -> model
    -> Sub msg
subscriptions (Page page_) =
    page_.subscriptions


toMsg :
    Page route flags contextModel contextMsg model msg appModel appMsg
    -> msg
    -> appMsg
toMsg (Page page_) =
    page_.toMsg


toModel :
    Page route flags contextModel contextMsg model msg appModel appMsg
    -> model
    -> appModel
toModel (Page page_) =
    page_.toModel

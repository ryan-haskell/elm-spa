module Application.Page exposing
    ( Context
    , Page
    , element
    , init
    , page
    , sandbox
    , static
    , subscriptions
    , update
    , view
    )

import Html exposing (Html)


type alias Context flags route contextModel =
    { flags : flags
    , route : route
    , context : contextModel
    }


type alias Page route flags contextModel contextMsg model msg appModel appMsg =
    { init : Context flags route contextModel -> ( model, Cmd msg, Cmd contextMsg )
    , update : Context flags route contextModel -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : Context flags route contextModel -> model -> Sub msg
    , view : Context flags route contextModel -> model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }



-- PAGE HELPERS


init :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    }
    -> Context flags route contextModel
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
init config context =
    config.page.init context
        |> mapTruple
            { fromMsg = config.page.toMsg
            , fromModel = config.page.toModel
            }


update :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , msg : msg
    , model : model
    }
    -> Context flags route contextModel
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
update config context =
    config.page.update context config.msg config.model
        |> mapTruple
            { fromMsg = config.page.toMsg
            , fromModel = config.page.toModel
            }


subscriptions :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , model : model
    }
    -> Context flags route contextModel
    -> Sub appMsg
subscriptions config context =
    config.page.subscriptions context config.model
        |> Sub.map config.page.toMsg


view :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , model : model
    }
    -> Context flags route contextModel
    -> Html appMsg
view config context =
    config.page.view context config.model
        |> Html.map config.page.toMsg



-- PAGE ADAPTERS


static :
    { view : Html Never
    , toModel : () -> appModel
    }
    -> Page route flags contextModel contextMsg () Never appModel appMsg
static config =
    { init = \c -> ( (), Cmd.none, Cmd.none )
    , update = \c m model -> ( model, Cmd.none, Cmd.none )
    , subscriptions = \c m -> Sub.none
    , view = \c m -> Html.map never config.view
    , toMsg = never
    , toModel = config.toModel
    }


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg
sandbox config =
    { init = \c -> ( config.init, Cmd.none, Cmd.none )
    , update = \c msg model -> ( config.update msg model, Cmd.none, Cmd.none )
    , subscriptions = \c m -> Sub.none
    , view = \c model -> config.view model
    , toMsg = config.toMsg
    , toModel = config.toModel
    }


element :
    { init : flags -> ( model, Cmd msg )
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
    { init = \c -> config.init c.flags |> appendCmd
    , update = \c msg model -> config.update msg model |> appendCmd
    , subscriptions = \c model -> config.subscriptions model
    , view = \c model -> config.view model
    , toMsg = config.toMsg
    , toModel = config.toModel
    }


page :
    { init : Context flags route contextModel -> ( model, Cmd msg )
    , update : Context flags route contextModel -> msg -> model -> ( model, Cmd msg )
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
    { init = \c -> config.init c |> appendCmd
    , update = \c msg model -> config.update c msg model |> appendCmd
    , subscriptions = \c model -> config.subscriptions c model
    , view = \c model -> config.view c model
    , toMsg = config.toMsg
    , toModel = config.toModel
    }



-- UTILS


mapTruple :
    { fromMsg : msg -> appMsg
    , fromModel : model -> appModel
    }
    -> ( model, Cmd msg, Cmd contextMsg )
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
mapTruple { fromModel, fromMsg } ( a, b, c ) =
    ( fromModel a
    , Cmd.map fromMsg b
    , c
    )

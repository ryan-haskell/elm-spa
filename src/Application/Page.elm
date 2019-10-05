module Application.Page exposing
    ( static, sandbox, element, page
    , init, update, bundle
    , Context
    , Bundle
    )

{-| A package for building single page apps with Elm!


# Page

These functions convert your pages into one consistent `Page` type.

This makes writing top-level functions like `init`, `update`, `view`, and `subscriptions` easy, without making pages themselves unnecessarily complex.

You can check out [a full example here](https://github.com/ryannhg/elm-app/tree/master/examples/basic) to understand how these functions are used.

@docs static, sandbox, element, page


# Helpers

@docs init, update, bundle


# Related types

@docs Context

@docs Bundle

-}

import Browser
import Html exposing (Html)


type alias Context flags route contextModel =
    { flags : flags
    , route : route
    , context : contextModel
    }


type alias Page route flags contextModel contextMsg model msg appModel appMsg =
    { title : Context flags route contextModel -> model -> String
    , init : Context flags route contextModel -> ( model, Cmd msg, Cmd contextMsg )
    , update : Context flags route contextModel -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : Context flags route contextModel -> model -> Sub msg
    , view : Context flags route contextModel -> model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }



-- PAGE HELPERS


init :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , context : Context flags route contextModel
    }
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
init config =
    config.page.init config.context
        |> mapTruple
            { fromMsg = config.page.toMsg
            , fromModel = config.page.toModel
            }


update :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , msg : msg
    , model : model
    , context : Context flags route contextModel
    }
    -> ( appModel, Cmd appMsg, Cmd contextMsg )
update config =
    config.page.update config.context config.msg config.model
        |> mapTruple
            { fromMsg = config.page.toMsg
            , fromModel = config.page.toModel
            }


type alias Bundle appMsg =
    { title : String
    , view : Html appMsg
    , subscriptions : Sub appMsg
    }


bundle :
    { page : Page route flags contextModel contextMsg model msg appModel appMsg
    , model : model
    , context : Context flags route contextModel
    }
    -> Bundle appMsg
bundle config =
    { title =
        config.page.title
            config.context
            config.model
    , view =
        Html.map config.page.toMsg <|
            config.page.view
                config.context
                config.model
    , subscriptions =
        Sub.map config.page.toMsg <|
            config.page.subscriptions
                config.context
                config.model
    }



-- PAGE ADAPTERS


static :
    { title : String
    , view : Html Never
    , toModel : () -> appModel
    }
    -> Page route flags contextModel contextMsg () Never appModel appMsg
static config =
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
    { title = config.title
    , init = config.init
    , update = config.update
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

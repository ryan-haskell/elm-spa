module Application exposing (Application, create)

{-|


## Applications

@docs Application, create


## Layouts

@docs Layout


## Transitions

@docs Transition, fade, none

-}

import Application.Page as Page
import Application.Route as Route
import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Utils as Utils
import Url exposing (Url)
import Url.Parser as Parser



-- APPLICATION


type alias Application flags globalModel globalMsg layoutModel layoutMsg =
    Platform.Program flags (Model flags globalModel layoutModel) (Msg globalMsg layoutMsg)


create :
    { routing :
        { routes : Routes route
        , toPath : route -> String
        , notFound : route
        }
    , global :
        { init :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> flags
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , update :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> globalMsg
            -> globalModel
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , subscriptions : globalModel -> Sub globalMsg
        }
    , page : Page.Page route layoutModel layoutMsg layoutModel layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg)
    }
    -> Application flags globalModel globalMsg layoutModel layoutMsg
create config =
    let
        page =
            config.page
                { toModel = identity
                , toMsg = identity
                }
    in
    Browser.application
        { init =
            init
                { init =
                    { global = config.global.init
                    , pages = page.init
                    }
                , routing =
                    { fromUrl = fromUrl config.routing
                    , toPath = config.routing.toPath
                    }
                }
        , update =
            update
                { routing =
                    { fromUrl = fromUrl config.routing
                    , toPath = config.routing.toPath
                    , routes = config.routing.routes
                    }
                , init = page.init
                , update =
                    { global = config.global.update
                    , pages = page.update
                    }
                }
        , subscriptions =
            subscriptions
                { bundle = page.bundle
                }
        , view =
            view
                { bundle = page.bundle
                }
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }



-- ROUTING


type alias Routes route =
    List (Route.Route route)


fromUrl : { a | routes : Routes route, notFound : route } -> Url -> route
fromUrl config =
    Parser.parse (Parser.oneOf config.routes)
        >> Maybe.withDefault config.notFound



-- INIT


type alias Model flags globalModel model =
    { url : Url
    , flags : flags
    , key : Nav.Key
    , global : globalModel
    , page : model
    }


init :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
        }
    , init :
        { global :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> flags
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , pages : route -> Page.Init layoutModel layoutMsg globalModel globalMsg
        }
    }
    -> flags
    -> Url
    -> Nav.Key
    -> ( Model flags globalModel layoutModel, Cmd (Msg globalMsg layoutMsg) )
init config flags url key =
    url
        |> config.routing.fromUrl
        |> (\route ->
                let
                    ( globalModel, globalCmd, cmd ) =
                        config.init.global
                            { navigate = navigate config.routing.toPath url
                            }
                            flags

                    ( pageModel, pageCmd, pageGlobalCmd ) =
                        config.init.pages route { global = globalModel }
                in
                ( { flags = flags
                  , url = url
                  , key = key
                  , global = globalModel
                  , page = pageModel
                  }
                , Cmd.batch
                    [ Cmd.map Page pageCmd
                    , Cmd.map Global pageGlobalCmd
                    , Cmd.map Global globalCmd
                    , cmd
                    ]
                )
           )



-- UPDATE


type Msg globalMsg msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | Global globalMsg
    | Page msg


update :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
        , routes : Routes route
        }
    , init : route -> Page.Init layoutModel layoutMsg globalModel globalMsg
    , update :
        { global :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg) }
            -> globalMsg
            -> globalModel
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , pages :
            layoutMsg
            -> layoutModel
            -> Page.Update layoutModel layoutMsg globalModel globalMsg
        }
    }
    -> Msg globalMsg layoutMsg
    -> Model flags globalModel layoutModel
    -> ( Model flags globalModel layoutModel, Cmd (Msg globalMsg layoutMsg) )
update config msg model =
    case msg of
        ClickedLink (Browser.Internal url) ->
            if url == model.url then
                ( model, Cmd.none )

            else
                ( model
                , Nav.pushUrl model.key (Url.toString url)
                )

        ClickedLink (Browser.External url) ->
            ( model
            , Nav.load url
            )

        ChangedUrl url ->
            url
                |> config.routing.fromUrl
                |> (\route -> config.init route { global = model.global })
                |> (\( pageModel, pageCmd, globalCmd ) ->
                        ( { model
                            | url = url
                            , page = pageModel
                          }
                        , Cmd.batch
                            [ Cmd.map Page pageCmd
                            , Cmd.map Global globalCmd
                            ]
                        )
                   )

        Global globalMsg ->
            config.update.global
                { navigate = navigate config.routing.toPath model.url
                }
                globalMsg
                model.global
                |> (\( global, globalCmd, cmd ) ->
                        ( { model | global = global }
                        , Cmd.batch
                            [ Cmd.map Global globalCmd
                            , cmd
                            ]
                        )
                   )

        Page pageMsg ->
            config.update.pages pageMsg model.page { global = model.global }
                |> (\( page, pageCmd, globalCmd ) ->
                        ( { model | page = page }
                        , Cmd.batch
                            [ Cmd.map Page pageCmd
                            , Cmd.map Global globalCmd
                            ]
                        )
                   )


navigate : (route -> String) -> Url -> route -> Cmd (Msg globalMsg layoutMsg)
navigate toPath url route =
    Utils.send <|
        ClickedLink (Browser.Internal { url | path = toPath route })



-- SUBSCRIPTIONS


subscriptions :
    { bundle :
        layoutModel
        -> Page.Bundle layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg)
    }
    -> Model flags globalModel layoutModel
    -> Sub (Msg globalMsg layoutMsg)
subscriptions config model =
    (config.bundle
        model.page
        { fromGlobalMsg = Global
        , fromPageMsg = Page
        , global = model.global
        }
    ).subscriptions



-- VIEW


view :
    { bundle :
        layoutModel
        -> Page.Bundle layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg)
    }
    -> Model flags globalModel layoutModel
    -> Browser.Document (Msg globalMsg layoutMsg)
view config model =
    { title = "elm-app demo"
    , body =
        [ config.bundle model.page
            { fromGlobalMsg = Global
            , fromPageMsg = Page
            , global = model.global
            }
            |> .view
        ]
    }

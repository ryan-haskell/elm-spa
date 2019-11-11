module App exposing
    ( Program, create
    , usingHtml
    )

{-|


## Let's build some single page applications!

`App.create` replaces [Browser.application](https://package.elm-lang.org/packages/elm/browser/latest/Browser#application)
as the entrypoint to your app.

    import App
    import Generated.Pages as Pages
    import Generated.Route as Route
    import Global

    main =
        App.create
            { ui = App.usingHtml
            , routing =
                { routes = Route.routes
                , toPath = Route.toPath
                , notFound = Route.NotFound ()
                }
            , global =
                { init = Global.init
                , update = Global.update
                , subscriptions = Global.subscriptions
                }
            , page = Pages.page
            }

@docs Program, create


# Supports more than elm/html

If you're a fan of [mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/),
it's important to support using `Element msg` instead of `Html msg` for your pages and components.

Let `App.create` know about this by passing in your own `Options` like these:

    import Element
    -- other imports

    App.create
        { ui =
            { toHtml = Element.layout []
            , map = Element.map
            }
        , -- ... the rest of your app
        }

@docs usingHtml

-}

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Page as Page
import Internals.Utils as Utils
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)



-- APPLICATION


{-| An alias for `Platform.Program` to make annotations a little more clear.
-}
type alias Program flags globalModel globalMsg layoutModel layoutMsg =
    Platform.Program flags (Model flags globalModel layoutModel) (Msg globalMsg layoutMsg)


{-| Pass this in when calling `App.create`

( It will work if your view returns the standard `Html msg` )

-}
usingHtml :
    { map :
        (layoutMsg -> Msg globalMsg layoutMsg)
        -> Html layoutMsg
        -> Html (Msg globalMsg layoutMsg)
    , toHtml : uiMsg -> uiMsg
    }
usingHtml =
    { toHtml = identity
    , map = Html.map
    }


{-| Creates a new `Program` given some one-time configuration:

  - `ui` - How do we convert the view to `Html msg`?
  - `routing` - What are the app's routes?
  - `global` - How do we manage shared state between pages?
  - `page` - What pages do we have available?

-}
create :
    { ui :
        { toHtml : uiMsg -> Html (Msg globalMsg layoutMsg)
        , map : (layoutMsg -> Msg globalMsg layoutMsg) -> uiLayoutMsg -> uiMsg
        }
    , routing :
        { routes : List (Parser (route -> route) route)
        , toPath : route -> String
        , notFound : route
        }
    , global :
        { init :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg)
            }
            -> flags
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , update :
            { navigate : route -> Cmd (Msg globalMsg layoutMsg)
            }
            -> globalMsg
            -> globalModel
            -> ( globalModel, Cmd globalMsg, Cmd (Msg globalMsg layoutMsg) )
        , subscriptions : globalModel -> Sub globalMsg
        }
    , page : Page.Page route layoutModel layoutMsg uiLayoutMsg layoutModel layoutMsg uiLayoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) uiMsg
    }
    -> Program flags globalModel globalMsg layoutModel layoutMsg
create config =
    let
        page =
            Page.upgrade
                { toModel = identity
                , toMsg = identity
                , page = config.page
                , map = always identity
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
                , map = config.ui.map
                , global = config.global.subscriptions
                }
        , view =
            view
                { toHtml = config.ui.toHtml
                , bundle = page.bundle
                , map = config.ui.map
                }
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }



-- ROUTING


type alias Routes route a =
    List (Parser (route -> a) a)


fromUrl : { a | routes : Routes route route, notFound : route } -> Url -> route
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
        , routes : Routes route a
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
    { map : (layoutMsg -> Msg globalMsg layoutMsg) -> uiLayoutMsg -> uiMsg
    , bundle :
        layoutModel
        -> Page.Bundle layoutMsg uiLayoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) uiMsg
    , global : globalModel -> Sub globalMsg
    }
    -> Model flags globalModel layoutModel
    -> Sub (Msg globalMsg layoutMsg)
subscriptions config model =
    Sub.batch
        [ (config.bundle
            model.page
            { fromGlobalMsg = Global
            , fromPageMsg = Page
            , global = model.global
            , map = config.map
            }
          ).subscriptions
        , Sub.map Global (config.global model.global)
        ]



-- VIEW


view :
    { map : (layoutMsg -> Msg globalMsg layoutMsg) -> uiLayoutMsg -> uiMsg
    , toHtml : uiMsg -> Html (Msg globalMsg layoutMsg)
    , bundle :
        layoutModel
        -> Page.Bundle layoutMsg uiLayoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) uiMsg
    }
    -> Model flags globalModel layoutModel
    -> Browser.Document (Msg globalMsg layoutMsg)
view config model =
    let
        bundle =
            config.bundle
                model.page
                { fromGlobalMsg = Global
                , fromPageMsg = Page
                , global = model.global
                , map = config.map
                }
    in
    { title = bundle.title
    , body =
        [ config.toHtml bundle.view
        ]
    }

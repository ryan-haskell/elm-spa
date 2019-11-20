module App exposing
    ( Program, create
    , usingHtml
    )

{-|


## Let's build some single page applications!

`App.create` replaces [Browser.application](https://package.elm-lang.org/packages/elm/browser/latest/Browser#application)
as the entrypoint to your app.

    import App
    import Global
    import Pages
    import Routes

    main =
        App.create
            { ui = App.usingHtml
            , routing =
                { routes = Routes.parsers
                , toPath = Routes.toPath
                , notFound = Routes.routes.notFound
                }
            , global =
                { init = Global.init
                , update = Global.update
                , subscriptions = Global.subscriptions
                }
            , page = Pages.page
            }

@docs Program, create


# using elm-ui?

If you're a big fan of [mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) (or not-so-big-fan of CSS),
this package supports using `Element msg` instead of `Html msg` for your pages and components.

Providing `App.create` with these `ui` options will do the trick!

    import Element

    main =
        App.create
            { ui =
                { toHtml = Element.layout []
                , map = Element.map
                }
            , -- ...
            }

@docs usingHtml

-}

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Page as Page
import Internals.Pattern as Pattern exposing (Pattern)
import Internals.Transition as Transition exposing (Transition)
import Internals.Utils as Utils
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)



-- APPLICATION


{-| An alias for `Platform.Program` to make annotations a little more clear.
-}
type alias Program flags globalModel globalMsg layoutModel layoutMsg =
    Platform.Program flags (Model flags globalModel layoutModel) (Msg globalMsg layoutMsg)


{-| Pass this in when calling `App.create`

    main =
        App.create
            { ui = App.usingHtml
            , -- ...
            }

-}
usingHtml :
    { map :
        (layoutMsg -> Msg globalMsg layoutMsg)
        -> Html layoutMsg
        -> Html (Msg globalMsg layoutMsg)
    , toHtml : ui_msg -> ui_msg
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
        { toHtml : ui_msg -> Html (Msg globalMsg layoutMsg)
        , map : (layoutMsg -> Msg globalMsg layoutMsg) -> ui_layoutMsg -> ui_msg
        }
    , routing :
        { routes : List (Parser (route -> route) route)
        , toPath : route -> String
        , notFound : route
        , transitions :
            { layout : Transition ui_msg
            , pages : List ( Pattern, Transition ui_msg )
            }
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
    , page : Page.Page route route layoutModel layoutMsg ui_layoutMsg layoutModel layoutMsg ui_layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) ui_msg
    }
    -> Program flags globalModel globalMsg layoutModel layoutMsg
create config =
    let
        page =
            Page.upgrade (always identity)
                { toModel = identity
                , toMsg = identity
                , page = config.page
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
                    , transition = config.routing.transitions.layout
                    }
                }
        , update =
            update
                { routing =
                    { fromUrl = fromUrl config.routing
                    , toPath = config.routing.toPath
                    , routes = config.routing.routes
                    , transitions = config.routing.transitions.pages
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
                , transition = config.routing.transitions.layout
                , fromUrl = fromUrl config.routing
                }
        , view =
            view
                { toHtml = config.ui.toHtml
                , bundle = page.bundle
                , map = config.ui.map
                , transition = config.routing.transitions.layout
                , fromUrl = fromUrl config.routing
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
    , transitioningPattern : Pattern
    , visibilities :
        { layout : Transition.Visibility
        , page : Transition.Visibility
        }
    }


init :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
        , transition : Transition ui_msg
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
                  , transitioningPattern = []
                  , visibilities =
                        { layout = Transition.invisible
                        , page = Transition.visible
                        }
                  }
                , Cmd.batch
                    [ Cmd.map Page pageCmd
                    , Cmd.map Global pageGlobalCmd
                    , Cmd.map Global globalCmd
                    , Utils.delay (Transition.speed config.routing.transition) FadeInLayout
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
    | FadeInLayout
    | FadeInPage Url


update :
    { routing :
        { fromUrl : Url -> route
        , toPath : route -> String
        , routes : Routes route a
        , transitions : List ( Pattern, Transition ui_msg )
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
        FadeInLayout ->
            ( { model
                | visibilities =
                    { layout = Transition.visible
                    , page = model.visibilities.page
                    }
              }
            , Cmd.none
            )

        FadeInPage url ->
            url
                |> config.routing.fromUrl
                |> (\route -> config.init route { global = model.global })
                |> (\( pageModel, pageCmd, globalCmd ) ->
                        ( { model
                            | visibilities = { layout = Transition.visible, page = Transition.visible }
                            , page = pageModel
                          }
                        , Cmd.batch
                            [ Cmd.map Page pageCmd
                            , Cmd.map Global globalCmd
                            ]
                        )
                   )

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
            let
                ( pattern, speed ) =
                    chooseFrom
                        { patternTransitions = config.routing.transitions
                        , from = model.url
                        , to = url
                        }
                        |> Just
                        |> Maybe.withDefault (List.head config.routing.transitions)
                        |> Maybe.map (Tuple.mapSecond Transition.speed)
                        |> Maybe.withDefault ( [], 0 )
            in
            ( { model
                | url = url
                , visibilities =
                    { layout = Transition.visible
                    , page = Transition.invisible
                    }
                , transitioningPattern = pattern
              }
            , Cmd.batch
                [ Utils.delay
                    speed
                    (FadeInPage url)
                ]
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
    { map : (layoutMsg -> Msg globalMsg layoutMsg) -> ui_layoutMsg -> ui_msg
    , bundle :
        layoutModel
        -> Page.Bundle route layoutMsg ui_layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) ui_msg
    , global : globalModel -> Sub globalMsg
    , transition : Transition ui_msg
    , fromUrl : Url -> route
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
            , transitioningPattern = model.transitioningPattern
            , visibility = model.visibilities.page
            , route = config.fromUrl model.url
            }
          ).subscriptions
        , Sub.map Global (config.global model.global)
        ]



-- VIEW


view :
    { map : (layoutMsg -> Msg globalMsg layoutMsg) -> ui_layoutMsg -> ui_msg
    , toHtml : ui_msg -> Html (Msg globalMsg layoutMsg)
    , bundle :
        layoutModel
        -> Page.Bundle route layoutMsg ui_layoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) ui_msg
    , transition : Transition ui_msg
    , fromUrl : Url -> route
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
                , transitioningPattern = model.transitioningPattern
                , visibility = model.visibilities.page
                , route = config.fromUrl model.url
                }
    in
    { title = bundle.title
    , body =
        [ config.toHtml <|
            Transition.view
                config.transition
                model.visibilities.layout
                { layout = identity, page = bundle.view }
        ]
    }



-- Transition magic


chooseFrom :
    { patternTransitions : List ( Pattern, Transition ui_msg )
    , from : Url
    , to : Url
    }
    -> Maybe ( Pattern, Transition ui_msg )
chooseFrom options =
    let
        ( fromPath, toPath ) =
            ( options.from, options.to )
                |> Tuple.mapBoth urlPath urlPath
    in
    options.patternTransitions
        |> List.reverse
        |> List.filter
            (\( pattern, transition ) ->
                Pattern.matches fromPath pattern
                    && Pattern.matches toPath pattern
                    && (transition /= Transition.optOut)
            )
        |> List.head


urlPath : Url -> List String
urlPath url =
    url.path |> String.dropLeft 1 |> String.split "/"

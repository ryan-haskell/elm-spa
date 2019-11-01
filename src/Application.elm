module Application exposing
    ( Program, create
    , Options, defaultOptions
    )

{-| Let's build some single page applications!


# Terrifying types ahead 😬

The `elm-spa` package makes your _functions look nice_,
but holy cow do those type annotations get intimidating!


## But why tho? 🤔

So much of the types are defined in _your app_, and this package needs
to use generic types to understand them correctly.

In practice, this actually leads to your code looking like this

    init route_ =
        case route_ of
            Route.Foo route ->
                foo.init route

            Route.Bar route ->
                bar.init route

            Route.Baz route ->
                baz.init route

            _ ->
                Page.keep model_

( Instead of a crazy nested torture chamber of doom )


## Anyway, enough excuses from me! 🤐

Check out the examples below to decide for yourself!


# Program

At a high-level, `elm-spa` replaces [Browser.application](https://package.elm-lang.org/packages/elm/browser/latest/Browser#application)
so you don't have to deal with `Url` or `Nav.Key`!

You can create a `Program` with `Application.create`:

    module Main exposing (main)

    import Application
    import Generated.Pages as Pages
    import Generated.Route as Route
    import Global

    main =
        Application.create
            { options = Application.defaultOptions
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


# Using elm-ui?

If you're a fan of [mdgriffith/elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/),
it's important to support using `Element msg` instead of `Html msg` for your pages and components.

Let `Application.create` know about this by passing in your own `Options` like these:

    import Element
    -- other imports

    Application.create
        { options =
            { toHtml = Element.layout []
            , map = Element.map
            }
        , -- ... the rest of your app
        }

@docs Options, defaultOptions

-}

import Application.Route as Route
import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Internals.Utils as Utils
import Url exposing (Url)
import Url.Parser as Parser
import Internals.Page as Page


-- APPLICATION


{-| An alias for `Platform.Program` to make annotations a little more clear.
-}
type alias Program flags globalModel globalMsg layoutModel layoutMsg =
    Platform.Program flags (Model flags globalModel layoutModel) (Msg globalMsg layoutMsg)



-- Options


{-| Useful for using packages like [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/)

    import Element

    options =
        { toHtml = Element.layout []
        , map = Element.map
        }

This tells your app how to convert into `Html msg` when it's time to render to the page.

-}
type alias Options layoutMsg globalMsg htmlLayoutMsg htmlMsg =
    { toHtml : htmlMsg -> Html (Msg globalMsg layoutMsg)
    , map : (layoutMsg -> Msg globalMsg layoutMsg) -> htmlLayoutMsg -> htmlMsg
    }


{-| Just using `elm/html`? Pass this in when calling `Application.create`

( It will work if your view returns the standard `Html msg` )

-}
defaultOptions : Options layoutMsg globalMsg (Html layoutMsg) (Html (Msg globalMsg layoutMsg))
defaultOptions =
    { toHtml = identity
    , map = Html.map
    }


{-| Creates a new `Program` given some one-time configuration:

  - `options` - How do we convert the view to `Html msg`?
  - `routing` - What are the app's routes?
  - `global` - How do we maintain the global app state
  - `page` - What pages do we have available?

-}
create :
    { options : Options layoutMsg globalMsg htmlLayoutMsg htmlMsg
    , routing :
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
    , page : Page.Page route layoutModel layoutMsg htmlLayoutMsg layoutModel layoutMsg htmlLayoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) htmlMsg
    }
    -> Program flags globalModel globalMsg layoutModel layoutMsg
create config =
    let
        page =
            Page.upgrade
                config.page
                { toModel = identity
                , toMsg = identity
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
                , map = config.options.map
                }
        , view =
            view
                { toHtml = config.options.toHtml
                , bundle = page.bundle
                , map = config.options.map
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
    { map : (layoutMsg -> Msg globalMsg layoutMsg) -> htmlLayoutMsg -> htmlMsg
    , bundle :
        layoutModel
        -> Page.Bundle layoutMsg htmlLayoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) htmlMsg
    }
    -> Model flags globalModel layoutModel
    -> Sub (Msg globalMsg layoutMsg)
subscriptions config model =
    (config.bundle
        model.page
        { fromGlobalMsg = Global
        , fromPageMsg = Page
        , global = model.global
        , map = config.map
        }
    ).subscriptions



-- VIEW


view :
    { map : (layoutMsg -> Msg globalMsg layoutMsg) -> htmlLayoutMsg -> htmlMsg
    , toHtml : htmlMsg -> Html (Msg globalMsg layoutMsg)
    , bundle :
        layoutModel
        -> Page.Bundle layoutMsg htmlLayoutMsg globalModel globalMsg (Msg globalMsg layoutMsg) htmlMsg
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

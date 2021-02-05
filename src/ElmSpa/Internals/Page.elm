module ElmSpa.Internals.Page exposing
    ( Page
    , static, sandbox, element, advanced
    , protected
    , Bundle, bundle
    )

{-|


# **Pages**

@docs Page

@docs static, sandbox, element, advanced


# **User Authentication**

@docs protected


# For generated code

@docs Bundle, bundle

-}

import Browser.Navigation exposing (Key)
import ElmSpa.Request
import Url exposing (Url)


{-| Pages are the building blocks of **elm-spa**.

Instead of importing this module, your project will have a `Page` module with a much simpler type:

    module Page exposing (Page, ...)

    type Page model msg

This makes all the generic `route`, `effect`, and `view` arguments disappear!

-}
type Page shared request route effect view model msg
    = Page (Internals shared request route effect view model msg)


{-| A page that only needs to render a static view.

    import Page

    page : Page () Never
    page =
        Page.static
            { view = view
            }

    -- view : View Never

-}
static :
    effect
    ->
        { view : view
        }
    -> Page shared request route effect view () msg
static none page =
    Page
        (\_ _ ->
            Ok
                { init = \_ -> ( (), none )
                , update = \_ _ -> ( (), none )
                , view = \_ -> page.view
                , subscriptions = \_ -> Sub.none
                }
        )


{-| A page that can keep track of application state.

( Inspired by [`Browser.sandbox`](https://package.elm-lang.org/packages/elm/browser/latest/Browser#sandbox) )

    import Page

    page : Page Model Msg
    page =
        Page.sandbox
            { init = init
            , update = update
            , view = view
            }

    -- init : Model
    -- update : Msg -> Model -> Model
    -- view : Model -> View Msg

-}
sandbox :
    effect
    ->
        { init : model
        , update : msg -> model -> model
        , view : model -> view
        }
    -> Page shared request route effect view model msg
sandbox none page =
    Page
        (\_ _ ->
            Ok
                { init = \_ -> ( page.init, none )
                , update = \msg model -> ( page.update msg model, none )
                , view = page.view
                , subscriptions = \_ -> Sub.none
                }
        )


{-| A page that can handle effects like [HTTP requests or subscriptions](https://guide.elm-lang.org/effects/).

( Inspired by [`Browser.element`](https://package.elm-lang.org/packages/elm/browser/latest/Browser#element) )

    import Page

    page : Page Model Msg
    page =
        Page.element
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

    -- init : ( Model, Cmd Msg )
    -- update : Msg -> Model -> ( Model, Cmd Msg )
    -- view : Model -> View Msg
    -- subscriptions : Model -> Sub Msg

-}
element :
    (Cmd msg -> effect)
    ->
        { init : ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , view : model -> view
        , subscriptions : model -> Sub msg
        }
    -> Page shared request route effect view model msg
element fromCmd page =
    Page
        (\_ _ ->
            Ok
                { init = \_ -> page.init |> Tuple.mapSecond fromCmd
                , update = \msg model -> page.update msg model |> Tuple.mapSecond fromCmd
                , view = page.view
                , subscriptions = page.subscriptions
                }
        )


{-| A page that can handles **custom** effects like sending a `Shared.Msg` or other general user-defined effects.

    import Effect
    import Page

    page : Page Model Msg
    page =
        Page.advanced
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

    -- init : ( Model, Effect Msg )
    -- update : Msg -> Model -> ( Model, Effect Msg )
    -- view : Model -> View Msg
    -- subscriptions : Model -> Sub Msg

-}
advanced :
    { init : ( model, effect )
    , update : msg -> model -> ( model, effect )
    , view : model -> view
    , subscriptions : model -> Sub msg
    }
    -> Page shared request route effect view model msg
advanced page =
    Page
        (\_ _ ->
            Ok
                { init = always page.init
                , update = page.update
                , view = page.view
                , subscriptions = page.subscriptions
                }
        )


{-| Prefixing any of the four functions above with `protected` will guarantee that the page has access to a user. Here's an example with `sandbox`:

    import Page

    page : Page Model Msg
    page =
        Page.protected.sandbox
            { init = init
            , update = update
            , view = view
            }

    -- init : User -> Model
    -- update : User -> Msg -> Model -> Model
    -- update : User -> Model -> View Msg

-}
protected :
    { effectNone : effect
    , fromCmd : Cmd msg -> effect
    , user : shared -> request -> Maybe user
    , route : route
    }
    ->
        { static :
            { view : user -> view
            }
            -> Page shared request route effect view () msg
        , sandbox :
            { init : user -> model
            , update : user -> msg -> model -> model
            , view : user -> model -> view
            }
            -> Page shared request route effect view model msg
        , element :
            { init : user -> ( model, Cmd msg )
            , update : user -> msg -> model -> ( model, Cmd msg )
            , view : user -> model -> view
            , subscriptions : user -> model -> Sub msg
            }
            -> Page shared request route effect view model msg
        , advanced :
            { init : user -> ( model, effect )
            , update : user -> msg -> model -> ( model, effect )
            , view : user -> model -> view
            , subscriptions : user -> model -> Sub msg
            }
            -> Page shared request route effect view model msg
        }
protected options =
    let
        protect pageWithUser page =
            Page
                (\shared req ->
                    case options.user shared req of
                        Just user ->
                            Ok (pageWithUser user page)

                        Nothing ->
                            Err options.route
                )
    in
    { static =
        protect
            (\user page ->
                { init = \_ -> ( (), options.effectNone )
                , update = \_ model -> ( model, options.effectNone )
                , view = \_ -> page.view user
                , subscriptions = \_ -> Sub.none
                }
            )
    , sandbox =
        protect
            (\user page ->
                { init = \_ -> ( page.init user, options.effectNone )
                , update = \msg model -> ( page.update user msg model, options.effectNone )
                , view = page.view user
                , subscriptions = \_ -> Sub.none
                }
            )
    , element =
        protect
            (\user page ->
                { init = \_ -> page.init user |> Tuple.mapSecond options.fromCmd
                , update = \msg model -> page.update user msg model |> Tuple.mapSecond options.fromCmd
                , view = page.view user
                , subscriptions = page.subscriptions user
                }
            )
    , advanced =
        protect
            (\user page ->
                { init = \_ -> page.init user
                , update = page.update user
                , view = page.view user
                , subscriptions = page.subscriptions user
                }
            )
    }



-- UPGRADING FOR GENERATED CODE


type alias Request route params =
    ElmSpa.Request.Request route params


{-| -}
type alias Bundle params model msg shared effect pagesModel pagesMsg pagesView =
    { init : params -> shared -> Url -> Key -> ( pagesModel, effect )
    , update : params -> msg -> model -> shared -> Url -> Key -> ( pagesModel, effect )
    , view : params -> model -> shared -> Url -> Key -> pagesView
    , subscriptions : params -> model -> shared -> Url -> Key -> Sub pagesMsg
    }


{-| This function is used by the generated code to connect your pages together.

It's big, spooky, and makes writing **elm-spa** pages really nice!

-}
bundle :
    { redirecting : { model : pagesModel, view : pagesView }
    , toRoute : Url -> route
    , toUrl : route -> String
    , fromCmd : Cmd any -> pagesEffect
    , mapEffect : effect -> pagesEffect
    , mapView : view -> pagesView
    , page : shared -> Request route params -> Page shared (Request route params) route effect view model msg
    , toModel : params -> model -> pagesModel
    , toMsg : msg -> pagesMsg
    }
    -> Bundle params model msg shared pagesEffect pagesModel pagesMsg pagesView



-- { init : params -> shared -> Url -> Key -> ( pagesModel, pagesEffect )
-- , update : params -> msg -> model -> shared -> Url -> Key -> ( pagesModel, pagesEffect )
-- , view : params -> model -> shared -> Url -> Key -> pagesView
-- , subscriptions : params -> model -> shared -> Url -> Key -> Sub pagesMsg
-- }


bundle { redirecting, toRoute, toUrl, fromCmd, mapEffect, mapView, page, toModel, toMsg } =
    { init =
        \params shared url key ->
            let
                req =
                    ElmSpa.Request.create (toRoute url) params url key
            in
            case toResult page shared req of
                Ok record ->
                    record.init ()
                        |> Tuple.mapBoth (toModel req.params) mapEffect

                Err route ->
                    ( redirecting.model, fromCmd <| Browser.Navigation.replaceUrl req.key (toUrl route) )
    , update =
        \params msg model shared url key ->
            let
                req =
                    ElmSpa.Request.create (toRoute url) params url key
            in
            case toResult page shared req of
                Ok record ->
                    record.update msg model
                        |> Tuple.mapBoth (toModel req.params) mapEffect

                Err route ->
                    ( redirecting.model, fromCmd <| Browser.Navigation.replaceUrl req.key (toUrl route) )
    , view =
        \params model shared url key ->
            let
                req =
                    ElmSpa.Request.create (toRoute url) params url key
            in
            case toResult page shared req of
                Ok record ->
                    record.view model
                        |> mapView

                Err _ ->
                    redirecting.view
    , subscriptions =
        \params model shared url key ->
            let
                req =
                    ElmSpa.Request.create (toRoute url) params url key
            in
            case toResult page shared req of
                Ok record ->
                    record.subscriptions model
                        |> Sub.map toMsg

                Err _ ->
                    Sub.none
    }


toResult :
    (shared -> Request route params -> Page shared (Request route params) route effect view model msg)
    -> shared
    -> Request route params
    -> Result route (PageRecord effect view model msg)
toResult toPage shared req =
    let
        (Page toResult_) =
            toPage shared req
    in
    toResult_ shared req



-- INTERNALS


type alias Internals shared request route effect view model msg =
    shared -> request -> Result route (PageRecord effect view model msg)


type alias PageRecord effect view model msg =
    { init : () -> ( model, effect )
    , update : msg -> model -> ( model, effect )
    , view : model -> view
    , subscriptions : model -> Sub msg
    }

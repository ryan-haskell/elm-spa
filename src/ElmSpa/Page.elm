module ElmSpa.Page exposing
    ( Page
    , static, sandbox, element, shared
    )

{-|


# **( These docs are for CLI contributors )**


### If you are using **elm-spa**, check out [the official guide](https://elm-spa.dev/guide) instead!

---

Every page in **elm-spa** ultimately becomes one data type: `Page`

This makes it easy to wire them up in the generated code, because they
all have the same type signature.

**Note:** You won't use `ElmSpa.Page` directly, instead you'll be using `Page`,
which removes some of the generic type parameters

    type alias Page model msg =
        { init : ( model, Cmd msg, List Shared.Msg )
        , update : msg -> model -> ( model, Cmd msg, List Shared.Msg )
        , view : model -> View msg
        , subscriptions : model -> Sub msg
        }


## Pages

@docs Page
@docs static, sandbox, element, shared

-}

import Browser.Navigation exposing (Key)
import ElmSpa.Request as Request exposing (Request)
import Url exposing (Url)


{-| The common `Page` type that each of the functions below creates

    Page.static { ... }    -- Page () Never
    Page.sandbox { ... }   -- Page Model Msg
    Page.element { ... }   -- Page Model Msg
    Page.shared { ... }    -- Page Model Msg

-}
type alias Page sharedMsg view model msg =
    { init : () -> ( model, Cmd msg, List sharedMsg )
    , update : msg -> model -> ( model, Cmd msg, List sharedMsg )
    , view : model -> view
    , subscriptions : model -> Sub msg
    }


{-| A page that can track state, and respond to user input.

    Page.static
        { view = view
        }

    view : View Never

-}
static :
    { view : view
    }
    -> Page sharedMsg view () Never
static options =
    { init = \_ -> ( (), Cmd.none, [] )
    , update = \_ _ -> ( (), Cmd.none, [] )
    , view = \_ -> options.view
    , subscriptions = \_ -> Sub.none
    }


{-| A page that can track state, and respond to user input.

    Page.sandbox
        { init = init
        , update = update
        , view = view
        }

    init : Model
    update : Msg -> Model -> Model
    view : Model -> View Msg

-}
sandbox :
    { init : model
    , update : msg -> model -> model
    , view : model -> view
    }
    -> Page sharedMsg view model msg
sandbox options =
    { init = \_ -> ( options.init, Cmd.none, [] )
    , update = \msg model -> ( options.update msg model, Cmd.none, [] )
    , view = options.view
    , subscriptions = \_ -> Sub.none
    }


{-| A page that can send side-effects and subscribe to events.

    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

    init : (Model, Cmd Msg)
    update : Msg -> Model -> (Model, Cmd Msg)
    view : Model -> View Msg
    subscriptions : Model -> Sub Msg

-}
element :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> view
    , subscriptions : model -> Sub msg
    }
    -> Page sharedMsg view model msg
element options =
    { init =
        \_ ->
            let
                ( model, cmd ) =
                    options.init
            in
            ( model, cmd, [] )
    , update =
        \msg_ model_ ->
            let
                ( model, cmd ) =
                    options.update msg_ model_
            in
            ( model, cmd, [] )
    , view = options.view
    , subscriptions = options.subscriptions
    }


{-| A page that allows messages to be sent to the `Shared` module.

    Page.shared
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

    init : (Model, Cmd Msg, List Shared.Msg )
    update : Msg -> Model -> (Model, Cmd Msg, List Shared.Msg )
    view : Model -> View Msg
    subscriptions : Model -> Sub Msg

-}
shared :
    { init : ( model, Cmd msg, List sharedMsg )
    , update : msg -> model -> ( model, Cmd msg, List sharedMsg )
    , view : model -> view
    , subscriptions : model -> Sub msg
    }
    -> Page sharedMsg view model msg
shared options =
    { init = \_ -> options.init
    , update = options.update
    , view = options.view
    , subscriptions = options.subscriptions
    }

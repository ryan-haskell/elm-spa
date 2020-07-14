module Spa.Page exposing
    ( Page
    , static, sandbox, element, application
    , Protected
    , protectedStatic, protectedSandbox, protectedElement, protectedFull
    , Upgraded, Bundle, upgrade
    )

{-|

@docs Page
@docs static, sandbox, element, application
@docs Protected
@docs protectedStatic, protectedSandbox, protectedElement, protectedFull
@docs Upgraded, Bundle, upgrade

-}

import Api.Data exposing (Data(..))
import Api.User exposing (User)
import Browser.Navigation as Nav
import Shared
import Spa.Document as Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Url exposing (Url)
import Url


type alias Page params model msg =
    { init : Shared.Model -> Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    , save : model -> Shared.Model -> Shared.Model
    , load : Shared.Model -> model -> ( model, Cmd msg )
    }


noEffect : model -> ( model, Cmd msg )
noEffect model =
    ( model, Cmd.none )


static :
    { view : Url params -> Document msg
    }
    -> Page params (Url params) msg
static page =
    { init = \_ url -> ( url, Cmd.none )
    , update = \_ model -> ( model, Cmd.none )
    , view = page.view
    , subscriptions = \_ -> Sub.none
    , save = always identity
    , load = always (identity >> noEffect)
    }


sandbox :
    { init : Url params -> model
    , update : msg -> model -> model
    , view : model -> Document msg
    }
    -> Page params model msg
sandbox page =
    { init = \_ url -> ( page.init url, Cmd.none )
    , update = \msg model -> ( page.update msg model, Cmd.none )
    , view = page.view
    , subscriptions = \_ -> Sub.none
    , save = always identity
    , load = always (identity >> noEffect)
    }


element :
    { init : Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    }
    -> Page params model msg
element page =
    { init = \_ params -> page.init params
    , update = \msg model -> page.update msg model
    , view = page.view
    , subscriptions = page.subscriptions
    , save = always identity
    , load = always (identity >> noEffect)
    }


application :
    { init : Shared.Model -> Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    , save : model -> Shared.Model -> Shared.Model
    , load : Shared.Model -> model -> ( model, Cmd msg )
    }
    -> Page params model msg
application =
    identity



-- PROTECTED, redirect to sign in if not signed in


type Protected params model
    = Protected model
    | Unprotected (Url params)


protectedStatic :
    { view : User -> Url params -> Document msg
    }
    -> Page params (Protected params { user : User, url : Url params }) msg
protectedStatic page =
    protected
        { init = \user _ url -> ( { url = url, user = user }, Cmd.none )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        , view = \{ user, url } -> page.view user url
        , save = always identity
        , load = always identity
        }


protectedSandbox :
    { init : User -> Url params -> model
    , update : msg -> model -> model
    , view : model -> Document msg
    }
    -> Page params (Protected params model) msg
protectedSandbox page =
    protected
        { init = \user _ url -> ( page.init user url, Cmd.none )
        , update = \msg model -> ( page.update msg model, Cmd.none )
        , view = page.view
        , subscriptions = always Sub.none
        , save = always identity
        , load = always identity
        }


protectedElement :
    { init : User -> Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    }
    -> Page params (Protected params model) msg
protectedElement page =
    protected
        { init = \user _ url -> page.init user url
        , update = page.update
        , view = page.view
        , subscriptions = page.subscriptions
        , save = always identity
        , load = always identity
        }


protectedFull :
    { init : User -> Shared.Model -> Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    , save : model -> Shared.Model -> Shared.Model
    , load : Shared.Model -> model -> model
    }
    -> Page params (Protected params model) msg
protectedFull =
    protected >> application


protected :
    { init : User -> Shared.Model -> Url params -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Document msg
    , subscriptions : model -> Sub msg
    , save : model -> Shared.Model -> Shared.Model
    , load : Shared.Model -> model -> model
    }
    -> Page params (Protected params model) msg
protected page =
    let
        init : Shared.Model -> Url params -> ( Protected params model, Cmd msg )
        init shared url =
            case shared.user of
                NotAsked ->
                    ( Unprotected url
                    , Nav.pushUrl shared.key (Route.toString Route.SignIn)
                    )

                Loading ->
                    ( Unprotected url
                    , Cmd.none
                    )

                Success user ->
                    page.init user shared url |> Tuple.mapFirst Protected

                Failure _ ->
                    ( Unprotected url
                    , Nav.pushUrl shared.key (Route.toString Route.SignIn)
                    )

        protect : (model -> value) -> value -> Protected params model -> value
        protect fromModel fallback protectedModel =
            case protectedModel of
                Protected model ->
                    fromModel model

                Unprotected _ ->
                    fallback
    in
    { init = init
    , update =
        \msg model_ ->
            protect
                (\model -> page.update msg model |> Tuple.mapFirst Protected)
                ( model_, Cmd.none )
                model_
    , view = protect page.view { title = "", body = [] }
    , subscriptions = protect page.subscriptions Sub.none
    , save = \model_ shared -> protect (\model -> page.save model shared) shared model_
    , load =
        \shared model_ ->
            case model_ of
                Protected model ->
                    page.load shared model |> Protected |> noEffect

                Unprotected url ->
                    init shared url
    }



-- UPGRADING


type alias Upgraded pageParams pageModel pageMsg model msg =
    { init : pageParams -> Shared.Model -> Url.Url -> ( model, Cmd msg )
    , update : pageMsg -> pageModel -> ( model, Cmd msg )
    , bundle : pageModel -> Bundle model msg
    }


type alias Bundle model msg =
    { view : Document msg
    , subscriptions : Sub msg
    , save : Shared.Model -> Shared.Model
    , load : Shared.Model -> ( model, Cmd msg )
    }


upgrade :
    (pageModel -> model)
    -> (pageMsg -> msg)
    -> Page pageParams pageModel pageMsg
    -> Upgraded pageParams pageModel pageMsg model msg
upgrade toModel toMsg page =
    { init = \params shared url -> page.init shared (Spa.Url.create params url) |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , update = \msg model -> page.update msg model |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model ->
            { view = page.view model |> Document.map toMsg
            , subscriptions = page.subscriptions model |> Sub.map toMsg
            , save = page.save model
            , load = \shared -> page.load shared model |> Tuple.mapBoth toModel (Cmd.map toMsg)
            }
    }

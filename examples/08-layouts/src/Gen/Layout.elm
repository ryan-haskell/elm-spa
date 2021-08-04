module Gen.Layout exposing
    ( Layout, static, sandbox
    , Bundle, toBundle
    --, element, advanced
    )

{-|

@docs Layout, static, sandbox, element, advanced
@docs Bundle, toBundle

-}

import Effect exposing (Effect)
import Request exposing (Request)
import Shared
import View exposing (View)



-- LAYOUT


type Layout model msg mainMsg
    = Layout (Internals model msg mainMsg)


static : { view : { viewPage : View mainMsg } -> View mainMsg } -> Layout () msg mainMsg
static layout =
    Layout
        { record =
            { init = ( (), Effect.none )
            , update = \_ model -> ( model, Effect.none )
            , view = \options _ -> layout.view { viewPage = options.viewPage }
            , subscriptions = \_ -> Sub.none
            }
        }


sandbox :
    { init : model
    , update : msg -> model -> model
    , view : { viewPage : View mainMsg, toMainMsg : msg -> mainMsg } -> model -> View mainMsg
    }
    -> Layout model msg mainMsg
sandbox layout =
    Layout
        { record =
            { init = ( layout.init, Effect.none )
            , update = \msg model -> ( layout.update msg model, Effect.none )
            , view = layout.view
            , subscriptions = \_ -> Sub.none
            }
        }



-- BUNDLE


type alias Internals model msg mainMsg =
    { record : LayoutRecord model msg mainMsg
    }


type alias LayoutRecord model msg mainMsg =
    { init : ( model, Effect msg )
    , update : msg -> model -> ( model, Effect msg )
    , subscriptions : model -> Sub msg
    , view :
        { viewPage : View mainMsg
        , toMainMsg : msg -> mainMsg
        }
        -> model
        -> View mainMsg
    }


type alias Bundle model msg genModel genMsg mainMsg =
    { init : Shared.Model -> Request -> ( genModel, Effect genMsg )
    , update : msg -> model -> Shared.Model -> Request -> ( genModel, Effect genMsg )
    , subscriptions : model -> Shared.Model -> Request -> Sub genMsg
    , view : model -> { viewPage : View mainMsg, toMainMsg : genMsg -> mainMsg } -> Shared.Model -> Request -> View mainMsg
    }


toBundle :
    (model -> genModel)
    -> (msg -> genMsg)
    -> (Shared.Model -> Request -> Layout model msg mainMsg)
    -> Bundle model msg genModel genMsg mainMsg
toBundle toModel toMsg toLayout =
    let
        toRecord shared req =
            case toLayout shared req of
                Layout { record } ->
                    record
    in
    { init =
        \shared req ->
            (toRecord shared req).init
                |> Tuple.mapBoth toModel (Effect.map toMsg)
    , update =
        \msg model shared req ->
            (toRecord shared req).update msg model
                |> Tuple.mapBoth toModel (Effect.map toMsg)
    , subscriptions =
        \model shared req ->
            (toRecord shared req).subscriptions model
                |> Sub.map toMsg
    , view =
        \model options shared req ->
            (toRecord shared req).view
                { viewPage = options.viewPage
                , toMainMsg = toMsg >> options.toMainMsg
                }
                model
    }

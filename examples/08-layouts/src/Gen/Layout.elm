module Gen.Layout exposing
    ( Layout, static
    , With, sandbox
    , Bundle, toBundle, toBundle2
    --, element, advanced
    )

{-|

@docs Layout, static
@docs With, sandbox, element, advanced
@docs Bundle, toBundle, toBundle2

-}

import Effect exposing (Effect)
import Request exposing (Request)
import Shared
import View exposing (View)



-- LAYOUT


type alias Layout mainMsg =
    With () Never mainMsg


type With model msg mainMsg
    = Layout (Internals model msg mainMsg)


static : { view : { viewPage : View mainMsg } -> View mainMsg } -> Layout mainMsg
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
    -> With model msg mainMsg
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
    -> (Shared.Model -> Request -> With model msg mainMsg)
    ->
        { init : Shared.Model -> Request -> ( genModel, Effect genMsg )
        , update : msg -> model -> Shared.Model -> Request -> ( genModel, Effect genMsg )
        , subscriptions : model -> Shared.Model -> Request -> Sub genMsg
        , view : model -> { viewPage : View mainMsg, toMainMsg : genMsg -> mainMsg } -> Shared.Model -> Request -> View mainMsg
        }
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


toBundle2 :
    (model1 -> model2 -> genModel)
    -> (msg1 -> genMsg)
    -> (msg2 -> genMsg)
    -> (Shared.Model -> Request -> With model1 msg1 mainMsg)
    -> (Shared.Model -> Request -> With model2 msg2 mainMsg)
    ->
        { init : Maybe model1 -> Shared.Model -> Request -> ( genModel, Effect genMsg )
        , update1 : model2 -> msg1 -> model1 -> Shared.Model -> Request -> ( genModel, Effect genMsg )
        , update2 : model1 -> msg2 -> model2 -> Shared.Model -> Request -> ( genModel, Effect genMsg )
        , subscriptions : model2 -> Shared.Model -> Request -> Sub genMsg
        , view : model2 -> { viewPage : View mainMsg, toMainMsg : genMsg -> mainMsg } -> Shared.Model -> Request -> View mainMsg
        }
toBundle2 toModel toMsg1 toMsg2 toLayout1 toLayout2 =
    let
        toRecord1 shared req =
            case toLayout1 shared req of
                Layout { record } ->
                    record

        toRecord2 shared req =
            case toLayout2 shared req of
                Layout { record } ->
                    record
    in
    { init =
        \maybeModel1 shared req ->
            case maybeModel1 of
                Just model1 ->
                    (toRecord2 shared req).init
                        |> Tuple.mapBoth (toModel model1) (Effect.map toMsg2)

                Nothing ->
                    let
                        ( model1, effect1 ) =
                            (toRecord1 shared req).init
                    in
                    (toRecord2 shared req).init
                        |> Tuple.mapBoth (toModel model1) (Effect.map toMsg2)
                        |> Tuple.mapSecond (\effect2 -> Effect.batch [ Effect.map toMsg1 effect1, effect2 ])
    , update1 =
        \model2 msg model shared req ->
            (toRecord1 shared req).update msg model
                |> Tuple.mapBoth (\model1 -> toModel model1 model2) (Effect.map toMsg1)
    , update2 =
        \model1 msg model shared req ->
            (toRecord2 shared req).update msg model
                |> Tuple.mapBoth (toModel model1) (Effect.map toMsg2)
    , subscriptions =
        \model shared req ->
            (toRecord2 shared req).subscriptions model
                |> Sub.map toMsg2
    , view =
        \model options shared req ->
            (toRecord2 shared req).view
                { viewPage = options.viewPage
                , toMainMsg = toMsg2 >> options.toMainMsg
                }
                model
    }

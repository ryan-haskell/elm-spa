module Gen.Layouts exposing
    ( Layout(..)
    , Model, init
    , Msg, update
    , view
    , subscriptions
    )

{-|

@docs Layout
@docs Model, init
@docs Msg, update
@docs view
@docs subscriptions

-}

import Effect exposing (Effect)
import Gen.Layout
import Layouts.Sidebar
import Layouts.Sidebar.Header
import Request exposing (Request)
import Shared
import View exposing (View)


type Layout
    = Sidebar
    | Sidebar__Header



-- BUNDLE


layouts =
    { sidebar = Gen.Layout.toBundle Sidebar_Model Sidebar_Msg Layouts.Sidebar.layout
    , sidebar__header = Gen.Layout.toBundle2 Sidebar__Header_Model Sidebar_Msg Sidebar__Header_Msg Layouts.Sidebar.layout Layouts.Sidebar.Header.layout
    }



-- INIT


type Model
    = Sidebar_Model Layouts.Sidebar.Model
    | Sidebar__Header_Model Layouts.Sidebar.Model ()


init : Maybe Model -> Layout -> Shared.Model -> Request -> ( Model, Effect Msg )
init maybeModel layout shared req =
    case layout of
        Sidebar ->
            case maybeModel of
                Just (Sidebar__Header_Model model1 _) ->
                    ( Sidebar_Model model1, Effect.none )

                _ ->
                    layouts.sidebar.init shared req

        Sidebar__Header ->
            case maybeModel of
                Just (Sidebar_Model model1) ->
                    layouts.sidebar__header.init (Just model1) shared req

                _ ->
                    layouts.sidebar__header.init Nothing shared req



-- UPDATE


type Msg
    = Sidebar_Msg Layouts.Sidebar.Msg
    | Sidebar__Header_Msg Never


update : Msg -> Model -> Shared.Model -> Request -> ( Model, Effect Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        ( Sidebar_Msg msg, Sidebar_Model model ) ->
            layouts.sidebar.update msg model

        ( Sidebar_Msg msg1, Sidebar__Header_Model model1 model2 ) ->
            layouts.sidebar__header.update1 model2 msg1 model1

        ( Sidebar__Header_Msg msg2, Sidebar__Header_Model model1 model2 ) ->
            layouts.sidebar__header.update2 model1 msg2 model2

        _ ->
            \_ _ -> ( model_, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Shared.Model -> Request -> Sub Msg
subscriptions model_ shared req =
    case model_ of
        Sidebar_Model model ->
            layouts.sidebar.subscriptions model shared req

        Sidebar__Header_Model model1 model2 ->
            Sub.batch
                [ layouts.sidebar.subscriptions model1 shared req
                , layouts.sidebar__header.subscriptions model2 shared req
                ]



-- VIEW


view :
    Model
    -> { viewPage : View mainMsg, toMainMsg : Msg -> mainMsg }
    -> Shared.Model
    -> Request
    -> View mainMsg
view model_ options shared req =
    case model_ of
        Sidebar_Model model ->
            layouts.sidebar.view model options shared req

        Sidebar__Header_Model model1 model2 ->
            layouts.sidebar.view model1 { options | viewPage = layouts.sidebar__header.view model2 options shared req } shared req

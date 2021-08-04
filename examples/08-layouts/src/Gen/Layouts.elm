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
import Request exposing (Request)
import Shared
import View exposing (View)


type Layout
    = Sidebar



-- BUNDLE


type alias Bundle model msg mainMsg =
    { init : Shared.Model -> Request -> ( Model, Effect Msg )
    , update : msg -> model -> Shared.Model -> Request -> ( Model, Effect Msg )
    , subscriptions : model -> Shared.Model -> Request -> Sub Msg
    , view : model -> { viewPage : View mainMsg, toMainMsg : Msg -> mainMsg } -> Shared.Model -> Request -> View mainMsg
    }


layouts :
    { sidebar : Bundle Layouts.Sidebar.Model Layouts.Sidebar.Msg mainMsg
    }
layouts =
    { sidebar = Gen.Layout.toBundle Sidebar_Model Sidebar_Msg Layouts.Sidebar.layout
    }



-- INIT


type Model
    = Sidebar_Model Layouts.Sidebar.Model


init : Layout -> Shared.Model -> Request -> ( Model, Effect Msg )
init layout =
    case layout of
        Sidebar ->
            layouts.sidebar.init



-- UPDATE


type Msg
    = Sidebar_Msg Layouts.Sidebar.Msg


update : Msg -> Model -> Shared.Model -> Request -> ( Model, Effect Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        ( Sidebar_Msg msg, Sidebar_Model model ) ->
            layouts.sidebar.update msg model



-- _ ->
--     \_ _ -> ( model_, Effect.none )
-- SUBSCRIPTIONS


subscriptions : Model -> Shared.Model -> Request -> Sub Msg
subscriptions model_ =
    case model_ of
        Sidebar_Model model ->
            layouts.sidebar.subscriptions model



-- VIEW


view :
    Model
    -> { viewPage : View mainMsg, toMainMsg : Msg -> mainMsg }
    -> Shared.Model
    -> Request
    -> View mainMsg
view model_ =
    case model_ of
        Sidebar_Model model ->
            layouts.sidebar.view model

module Main exposing (main)

import Application
import Html exposing (Html)
import Pages.Counter as Counter
import Pages.Homepage as Homepage
import Pages.NotFound as NotFound


main : Program () Model Msg
main =
    Application.create
        { route = Counter
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }



-- CAN / SHOULD BE GENERATED


type Route
    = Homepage
    | Counter
    | NotFound


type Model
    = HomepageModel Homepage.Model
    | CounterModel Counter.Model
    | NotFoundModel NotFound.Model


type Msg
    = HomepageMsg Homepage.Msg
    | CounterMsg Counter.Msg
    | NotFoundMsg NotFound.Msg


homepage : Application.Recipe Homepage.Model Homepage.Msg Model Msg
homepage =
    Homepage.page
        { toModel = HomepageModel
        , toMsg = HomepageMsg
        }


counter : Application.Recipe Counter.Model Counter.Msg Model Msg
counter =
    Counter.page
        { toModel = CounterModel
        , toMsg = CounterMsg
        }


notFound : Application.Recipe NotFound.Model NotFound.Msg Model Msg
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }


init : Route -> Model
init route =
    case route of
        Homepage ->
            homepage.init

        Counter ->
            counter.init

        NotFound ->
            notFound.init


update : Msg -> Model -> Model
update appMsg appModel =
    case ( appMsg, appModel ) of
        ( HomepageMsg msg, HomepageModel model ) ->
            homepage.update msg model

        ( HomepageMsg _, _ ) ->
            Application.keep appModel

        ( CounterMsg msg, CounterModel model ) ->
            counter.update msg model

        ( CounterMsg _, _ ) ->
            Application.keep appModel

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        ( NotFoundMsg _, _ ) ->
            Application.keep appModel


bundle : Model -> { view : Html Msg }
bundle appModel =
    case appModel of
        HomepageModel model ->
            homepage.bundle model

        CounterModel model ->
            counter.bundle model

        NotFoundModel model ->
            notFound.bundle model

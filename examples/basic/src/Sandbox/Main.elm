module Sandbox.Main exposing (main)

import Application.Sandbox as Application
import Sandbox.Pages.Counter as Counter
import Sandbox.Pages.Homepage as Homepage
import Sandbox.Pages.NotFound as NotFound


type Route
    = Homepage
    | Counter
    | NotFound


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


type Model
    = HomepageModel Homepage.Model
    | CounterModel Counter.Model
    | NotFoundModel NotFound.Model


type Msg
    = HomepageMsg Homepage.Msg
    | CounterMsg Counter.Msg
    | NotFoundMsg NotFound.Msg



-- CAN / SHOULD BE GENERATED


type alias Pages =
    { homepage : Application.Page Homepage.Model Homepage.Msg Model Msg
    , counter : Application.Page Counter.Model Counter.Msg Model Msg
    , notFound : Application.Page NotFound.Model NotFound.Msg Model Msg
    }


pages : Pages
pages =
    { homepage =
        Homepage.page
            { toModel = HomepageModel
            , toMsg = HomepageMsg
            }
    , counter =
        Counter.page
            { toModel = CounterModel
            , toMsg = CounterMsg
            }
    , notFound =
        NotFound.page
            { toModel = NotFoundModel
            , toMsg = NotFoundMsg
            }
    }


init : Route -> Application.Init Model
init route =
    case route of
        Homepage ->
            Application.init pages.homepage

        Counter ->
            Application.init pages.counter

        NotFound ->
            Application.init pages.notFound


update : Msg -> Model -> Application.Update Model
update appMsg appModel =
    case ( appMsg, appModel ) of
        ( HomepageMsg msg, HomepageModel model ) ->
            Application.update
                { page = pages.homepage
                , model = model
                , msg = msg
                }

        ( HomepageMsg _, _ ) ->
            Application.keep appModel

        ( CounterMsg msg, CounterModel model ) ->
            Application.update
                { page = pages.counter
                , model = model
                , msg = msg
                }

        ( CounterMsg _, _ ) ->
            Application.keep appModel

        ( NotFoundMsg msg, NotFoundModel model ) ->
            Application.update
                { page = pages.notFound
                , model = model
                , msg = msg
                }

        ( NotFoundMsg _, _ ) ->
            Application.keep appModel


bundle : Model -> Application.Bundle Model Msg
bundle appModel =
    case appModel of
        HomepageModel model ->
            Application.bundle
                { page = pages.homepage
                , model = model
                }

        CounterModel model ->
            Application.bundle
                { page = pages.counter
                , model = model
                }

        NotFoundModel model ->
            Application.bundle
                { page = pages.notFound
                , model = model
                }

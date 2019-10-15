module Element.Main exposing (main)

import Application.Element as Application
import Element.Pages.Counter as Counter
import Element.Pages.Homepage as Homepage
import Element.Pages.NotFound as NotFound
import Element.Pages.Random as Random


type Route
    = Homepage
    | Counter
    | Random
    | NotFound


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Application.create
        { route = Random
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


type Model
    = HomepageModel Homepage.Model
    | CounterModel Counter.Model
    | RandomModel Random.Model
    | NotFoundModel NotFound.Model


type Msg
    = HomepageMsg Homepage.Msg
    | CounterMsg Counter.Msg
    | RandomMsg Random.Msg
    | NotFoundMsg NotFound.Msg



-- CAN / SHOULD BE GENERATED


type alias Pages =
    { homepage : Application.Page Flags Homepage.Model Homepage.Msg Model Msg
    , counter : Application.Page Flags Counter.Model Counter.Msg Model Msg
    , random : Application.Page Flags Random.Model Random.Msg Model Msg
    , notFound : Application.Page Flags NotFound.Model NotFound.Msg Model Msg
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
    , random =
        Random.page
            { toModel = RandomModel
            , toMsg = RandomMsg
            }
    , notFound =
        NotFound.page
            { toModel = NotFoundModel
            , toMsg = NotFoundMsg
            }
    }


init : Route -> Application.Init Flags Model Msg
init route =
    case route of
        Homepage ->
            Application.init pages.homepage

        Counter ->
            Application.init pages.counter

        Random ->
            Application.init pages.random

        NotFound ->
            Application.init pages.notFound


update : Msg -> Model -> Application.Update Model Msg
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

        ( RandomMsg msg, RandomModel model ) ->
            Application.update
                { page = pages.random
                , model = model
                , msg = msg
                }

        ( RandomMsg _, _ ) ->
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

        RandomModel model ->
            Application.bundle
                { page = pages.random
                , model = model
                }

        NotFoundModel model ->
            Application.bundle
                { page = pages.notFound
                , model = model
                }

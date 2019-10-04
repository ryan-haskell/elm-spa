module App exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Application.Page as Page exposing (Context)
import Context
import Flags exposing (Flags)
import Html exposing (Html)
import Pages.Counter
import Pages.Homepage
import Pages.NotFound
import Pages.Random
import Route exposing (Route)


type Model
    = HomepageModel ()
    | CounterModel Pages.Counter.Model
    | RandomModel Pages.Random.Model
    | NotFoundModel ()


type Msg
    = HomepageMsg Never
    | CounterMsg Pages.Counter.Msg
    | RandomMsg Pages.Random.Msg
    | NotFoundMsg Never


pages =
    { homepage =
        Page.static
            { view = Pages.Homepage.view
            , toModel = HomepageModel
            }
    , counter =
        Page.sandbox
            { init = Pages.Counter.init
            , update = Pages.Counter.update
            , view = Pages.Counter.view
            , toModel = CounterModel
            , toMsg = CounterMsg
            }
    , random =
        Page.element
            { init = Pages.Random.init
            , update = Pages.Random.update
            , subscriptions = Pages.Random.subscriptions
            , view = Pages.Random.view
            , toModel = RandomModel
            , toMsg = RandomMsg
            }
    , notFound =
        Page.static
            { view = Pages.NotFound.view
            , toModel = NotFoundModel
            }
    }


init :
    Context Flags Route Context.Model
    -> ( Model, Cmd Msg, Cmd Context.Msg )
init context =
    case context.route of
        Route.Homepage ->
            Page.init
                { page = pages.homepage }
                context

        Route.Counter ->
            Page.init
                { page = pages.counter }
                context

        Route.Random ->
            Page.init
                { page = pages.random }
                context

        Route.NotFound ->
            Page.init
                { page = pages.notFound }
                context


update :
    Context Flags Route Context.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd Context.Msg )
update context appMsg appModel =
    case ( appModel, appMsg ) of
        ( HomepageModel model, HomepageMsg msg ) ->
            Page.update
                { page = pages.homepage
                , msg = msg
                , model = model
                }
                context

        ( HomepageModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( CounterModel model, CounterMsg msg ) ->
            Page.update
                { page = pages.counter
                , msg = msg
                , model = model
                }
                context

        ( CounterModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( RandomModel model, RandomMsg msg ) ->
            Page.update
                { page = pages.random
                , msg = msg
                , model = model
                }
                context

        ( RandomModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( NotFoundModel model, NotFoundMsg msg ) ->
            Page.update
                { page = pages.notFound
                , msg = msg
                , model = model
                }
                context

        ( NotFoundModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )


subscriptions :
    Context Flags Route Context.Model
    -> Model
    -> Sub Msg
subscriptions context appModel =
    case appModel of
        HomepageModel model ->
            Page.subscriptions
                { page = pages.homepage
                , model = model
                }
                context

        CounterModel model ->
            Page.subscriptions
                { page = pages.counter
                , model = model
                }
                context

        RandomModel model ->
            Page.subscriptions
                { page = pages.random
                , model = model
                }
                context

        NotFoundModel model ->
            Page.subscriptions
                { page = pages.notFound
                , model = model
                }
                context


view :
    Context Flags Route Context.Model
    -> Model
    -> Html Msg
view context appModel =
    case appModel of
        HomepageModel model ->
            Page.view
                { page = pages.homepage
                , model = model
                }
                context

        CounterModel model ->
            Page.view
                { page = pages.counter
                , model = model
                }
                context

        RandomModel model ->
            Page.view
                { page = pages.random
                , model = model
                }
                context

        NotFoundModel model ->
            Page.view
                { page = pages.notFound
                , model = model
                }
                context

module Pages exposing
    ( Model
    , Msg
    , bundle
    , init
    , update
    )

import Application exposing (Bundle, Context)
import Application.Page as Page
import Browser
import Flags exposing (Flags)
import Global
import Html exposing (Html)
import Pages.Counter
import Pages.Homepage
import Pages.NotFound
import Pages.Random
import Pages.SignIn
import Route exposing (Route)


type Model
    = HomepageModel ()
    | CounterModel Pages.Counter.Model
    | RandomModel Pages.Random.Model
    | SignInModel Pages.SignIn.Model
    | NotFoundModel ()


type Msg
    = HomepageMsg Never
    | CounterMsg Pages.Counter.Msg
    | RandomMsg Pages.Random.Msg
    | SignInMsg Pages.SignIn.Msg
    | NotFoundMsg Never


pages =
    { homepage =
        Page.static
            { title = Pages.Homepage.title
            , view = Pages.Homepage.view
            , toModel = HomepageModel
            }
    , counter =
        Page.sandbox
            { title = Pages.Counter.title
            , init = Pages.Counter.init
            , update = Pages.Counter.update
            , view = Pages.Counter.view
            , toModel = CounterModel
            , toMsg = CounterMsg
            }
    , random =
        Page.element
            { title = Pages.Random.title
            , init = Pages.Random.init
            , update = Pages.Random.update
            , subscriptions = Pages.Random.subscriptions
            , view = Pages.Random.view
            , toModel = RandomModel
            , toMsg = RandomMsg
            }
    , signIn =
        Page.page
            { title = Pages.SignIn.title
            , init = Pages.SignIn.init
            , update = Pages.SignIn.update
            , subscriptions = Pages.SignIn.subscriptions
            , view = Pages.SignIn.view
            , toModel = SignInModel
            , toMsg = SignInMsg
            }
    , notFound =
        Page.static
            { title = Pages.NotFound.title
            , view = Pages.NotFound.view
            , toModel = NotFoundModel
            }
    }


init :
    Route
    -> Context Flags Route Global.Model
    -> ( Model, Cmd Msg, Cmd Global.Msg )
init route =
    case route of
        Route.Homepage ->
            Application.init
                { page = pages.homepage
                }

        Route.Counter ->
            Application.init
                { page = pages.counter
                }

        Route.Random ->
            Application.init
                { page = pages.random
                }

        Route.SignIn ->
            Application.init
                { page = pages.signIn
                }

        Route.NotFound ->
            Application.init
                { page = pages.notFound
                }


update :
    Msg
    -> Model
    -> Context Flags Route Global.Model
    -> ( Model, Cmd Msg, Cmd Global.Msg )
update appMsg appModel =
    case ( appModel, appMsg ) of
        ( HomepageModel model, HomepageMsg msg ) ->
            Application.update
                { page = pages.homepage
                , msg = msg
                , model = model
                }

        ( HomepageModel _, _ ) ->
            Application.keep appModel

        ( CounterModel model, CounterMsg msg ) ->
            Application.update
                { page = pages.counter
                , msg = msg
                , model = model
                }

        ( CounterModel _, _ ) ->
            Application.keep appModel

        ( RandomModel model, RandomMsg msg ) ->
            Application.update
                { page = pages.random
                , msg = msg
                , model = model
                }

        ( RandomModel _, _ ) ->
            Application.keep appModel

        ( SignInModel model, SignInMsg msg ) ->
            Application.update
                { page = pages.signIn
                , msg = msg
                , model = model
                }

        ( SignInModel _, _ ) ->
            Application.keep appModel

        ( NotFoundModel model, NotFoundMsg msg ) ->
            Application.update
                { page = pages.notFound
                , msg = msg
                , model = model
                }

        ( NotFoundModel _, _ ) ->
            Application.keep appModel


bundle :
    Model
    -> Context Flags Route Global.Model
    -> Bundle Msg
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

        SignInModel model ->
            Application.bundle
                { page = pages.signIn
                , model = model
                }

        NotFoundModel model ->
            Application.bundle
                { page = pages.notFound
                , model = model
                }

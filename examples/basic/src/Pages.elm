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
    Context Flags Route Global.Model
    -> ( Model, Cmd Msg, Cmd Global.Msg )
init context =
    case context.route of
        Route.Homepage ->
            Application.init
                { page = pages.homepage
                , context = context
                }

        Route.Counter ->
            Application.init
                { page = pages.counter
                , context = context
                }

        Route.Random ->
            Application.init
                { page = pages.random
                , context = context
                }

        Route.SignIn ->
            Application.init
                { page = pages.signIn
                , context = context
                }

        Route.NotFound ->
            Application.init
                { page = pages.notFound
                , context = context
                }


update :
    Context Flags Route Global.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Cmd Global.Msg )
update context appMsg appModel =
    case ( appModel, appMsg ) of
        ( HomepageModel model, HomepageMsg msg ) ->
            Application.update
                { page = pages.homepage
                , msg = msg
                , model = model
                , context = context
                }

        ( HomepageModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( CounterModel model, CounterMsg msg ) ->
            Application.update
                { page = pages.counter
                , msg = msg
                , model = model
                , context = context
                }

        ( CounterModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( RandomModel model, RandomMsg msg ) ->
            Application.update
                { page = pages.random
                , msg = msg
                , model = model
                , context = context
                }

        ( RandomModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( SignInModel model, SignInMsg msg ) ->
            Application.update
                { page = pages.signIn
                , msg = msg
                , model = model
                , context = context
                }

        ( SignInModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )

        ( NotFoundModel model, NotFoundMsg msg ) ->
            Application.update
                { page = pages.notFound
                , msg = msg
                , model = model
                , context = context
                }

        ( NotFoundModel _, _ ) ->
            ( appModel
            , Cmd.none
            , Cmd.none
            )


bundle :
    Context Flags Route Global.Model
    -> Model
    -> Bundle Msg
bundle context appModel =
    case appModel of
        HomepageModel model ->
            Application.bundle
                { page = pages.homepage
                , model = model
                , context = context
                }

        CounterModel model ->
            Application.bundle
                { page = pages.counter
                , model = model
                , context = context
                }

        RandomModel model ->
            Application.bundle
                { page = pages.random
                , model = model
                , context = context
                }

        SignInModel model ->
            Application.bundle
                { page = pages.signIn
                , model = model
                , context = context
                }

        NotFoundModel model ->
            Application.bundle
                { page = pages.notFound
                , model = model
                , context = context
                }

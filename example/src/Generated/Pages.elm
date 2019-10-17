module Generated.Pages exposing (Model, Msg, bundle, init, update)

import Application
import Generated.Route as Route exposing (Route)
import Html exposing (Html)
import Pages.Counter as Counter
import Pages.Homepage as Homepage
import Pages.NotFound as NotFound
import Pages.Random as Random
import Pages.Users.Slug as Users_Slug


type Model
    = HomepageModel Homepage.Model
    | CounterModel Counter.Model
    | RandomModel Random.Model
    | NotFoundModel NotFound.Model
    | Users_SlugModel Users_Slug.Model


type Msg
    = HomepageMsg Homepage.Msg
    | CounterMsg Counter.Msg
    | RandomMsg Random.Msg
    | NotFoundMsg NotFound.Msg
    | Users_SlugMsg Users_Slug.Msg


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


random : Application.Recipe Random.Model Random.Msg Model Msg
random =
    Random.page
        { toModel = RandomModel
        , toMsg = RandomMsg
        }


notFound : Application.Recipe NotFound.Model NotFound.Msg Model Msg
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        }


users_slug : Application.RecipeWithParams Users_Slug.Model Users_Slug.Msg Model Msg String
users_slug =
    Users_Slug.page
        { toModel = Users_SlugModel
        , toMsg = Users_SlugMsg
        }


init : Route -> ( Model, Cmd Msg )
init route =
    case route of
        Route.Homepage ->
            homepage.init

        Route.Counter ->
            counter.init

        Route.Random ->
            random.init

        Route.NotFound ->
            notFound.init

        Route.Users_Slug slug ->
            users_slug.init slug


update : Msg -> Model -> ( Model, Cmd Msg )
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

        ( RandomMsg msg, RandomModel model ) ->
            random.update msg model

        ( RandomMsg _, _ ) ->
            Application.keep appModel

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        ( NotFoundMsg _, _ ) ->
            Application.keep appModel

        ( Users_SlugMsg msg, Users_SlugModel model ) ->
            users_slug.update msg model

        ( Users_SlugMsg _, _ ) ->
            Application.keep appModel


bundle : Model -> { view : Html Msg, subscriptions : Sub Msg }
bundle appModel =
    case appModel of
        HomepageModel model ->
            homepage.bundle model

        CounterModel model ->
            counter.bundle model

        RandomModel model ->
            random.bundle model

        NotFoundModel model ->
            notFound.bundle model

        Users_SlugModel model ->
            users_slug.bundle model

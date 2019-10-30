module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page exposing (Page)
import Element exposing (Element)
import Generated.Route as Route exposing (Route)
import Global
import Layouts.Main as Layout
import Pages.Index as Index
import Pages.NotFound as NotFound
import Pages.SignIn as SignIn



-- MODEL & MSG


type Model
    = IndexModel Index.Model
    | NotFoundModel NotFound.Model
    | SignInModel SignIn.Model


type Msg
    = IndexMsg Index.Msg
    | NotFoundMsg NotFound.Msg
    | SignInMsg SignIn.Msg


page : Page Route Model Msg (Element Msg) a b (Element b) Global.Model Global.Msg c (Element c)
page =
    Page.layout
        { map = Element.map
        , layout = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }



-- RECIPES


type alias Recipe params model msg a =
    Page.Recipe params model msg Model Msg (Element Msg) Global.Model Global.Msg a (Element a)


index : Recipe Route.IndexParams Index.Model Index.Msg a
index =
    Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        , map = Element.map
        }


notFound : Recipe Route.NotFoundParams NotFound.Model NotFound.Msg a
notFound =
    NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        , map = Element.map
        }


signIn : Recipe Route.SignInParams SignIn.Model SignIn.Msg a
signIn =
    SignIn.page
        { toModel = SignInModel
        , toMsg = SignInMsg
        , map = Element.map
        }



-- INIT


init : Route -> Page.Init Model Msg Global.Model Global.Msg
init route_ =
    case route_ of
        Route.Index route ->
            index.init route

        Route.NotFound route ->
            notFound.init route

        Route.SignIn route ->
            signIn.init route



-- UPDATE


update : Msg -> Model -> Page.Update Model Msg Global.Model Global.Msg
update msg_ model_ =
    case ( msg_, model_ ) of
        ( IndexMsg msg, IndexModel model ) ->
            index.update msg model

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        ( SignInMsg msg, SignInModel model ) ->
            signIn.update msg model

        _ ->
            Page.keep model_



-- BUNDLE


bundle : Model -> Page.Bundle Msg (Element Msg) Global.Model Global.Msg a (Element a)
bundle model_ =
    case model_ of
        IndexModel model ->
            index.bundle model

        NotFoundModel model ->
            notFound.bundle model

        SignInModel model ->
            signIn.bundle model

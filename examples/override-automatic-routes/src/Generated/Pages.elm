module Generated.Pages exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page

import Generated.Route as Route
import Html
import Layouts.Main as Layout
import Pages.Index as Index
import Pages.NotFound as NotFound
import Pages.SomePage as SomePage


type Model
    = IndexModel Index.Model
    | NotFoundModel NotFound.Model
    | SomePageModel SomePage.Model


type Msg
    = IndexMsg Index.Msg
    | NotFoundMsg NotFound.Msg
    | SomePageMsg SomePage.Msg


page =
    Page.layout
        { map = Html.map
        , view = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


index =
        Page.recipe Index.page
        { toModel = IndexModel
        , toMsg = IndexMsg
        , map = Html.map
        }


notFound =
        Page.recipe NotFound.page
        { toModel = NotFoundModel
        , toMsg = NotFoundMsg
        , map = Html.map
        }


somePage =
        Page.recipe SomePage.page
        { toModel = SomePageModel
        , toMsg = SomePageMsg
        , map = Html.map
        }


init route_ =
    case route_ of
        Route.Index route ->
            index.init route

        Route.NotFound route ->
            notFound.init route

        Route.SomePage route ->
            somePage.init route


update msg_ model_ =
    case ( msg_, model_ ) of
        ( IndexMsg msg, IndexModel model ) ->
            index.update msg model

        ( NotFoundMsg msg, NotFoundModel model ) ->
            notFound.update msg model

        ( SomePageMsg msg, SomePageModel model ) ->
            somePage.update msg model

        _ ->
            Page.keep model_


bundle model_ =
    case model_ of
        IndexModel model ->
            index.bundle model

        NotFoundModel model ->
            notFound.bundle model

        SomePageModel model ->
            somePage.bundle model


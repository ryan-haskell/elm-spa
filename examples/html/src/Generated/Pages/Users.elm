module Generated.Pages.Users exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Page

import Generated.Route.Users as Route
import Html
import Layouts.Users as Layout
import Pages.Users.Slug as Slug


type Model
    = SlugModel Slug.Model


type Msg
    = SlugMsg Slug.Msg


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


slug =
    Slug.page
        { toModel = SlugModel
        , toMsg = SlugMsg
        , map = Html.map
        }


init route_ =
    case route_ of
        Route.Slug route ->
            slug.init route


update msg_ model_ =
    case ( msg_, model_ ) of
        ( SlugMsg msg, SlugModel model ) ->
            slug.update msg model



bundle model_ =
    case model_ of
        SlugModel model ->
            slug.bundle model


module Generated.Pages.Users exposing
    ( Model
    , Msg
    , page
    )

import Application.Page as Application
import Generated.Route.Users as Route exposing (Route)
import Global
import Html exposing (..)
import Layouts.Users as Layout
import Pages.Users.Slug as Slug


type Model
    = SlugModel Slug.Model


type Msg
    = SlugMsg Slug.Msg


page : Application.Page Route Model Msg a b Global.Model Global.Msg c
page =
    Application.layout
        { layout = Layout.layout
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


slug : Application.Recipe Route.SlugParams Slug.Model Slug.Msg Model Msg Global.Model Global.Msg a
slug =
    Slug.page
        { toModel = SlugModel
        , toMsg = SlugMsg
        }


init : Route -> Application.Init Model Msg Global.Model Global.Msg
init route_ =
    case route_ of
        Route.Slug route ->
            slug.init route


update : Msg -> Model -> Application.Update Model Msg Global.Model Global.Msg
update msg_ model_ =
    case ( msg_, model_ ) of
        ( SlugMsg msg, SlugModel model ) ->
            slug.update msg model



-- _ ->
--     Application.keep model_


bundle : Model -> Application.Bundle Msg Global.Model Global.Msg msg
bundle model_ =
    case model_ of
        SlugModel model ->
            slug.bundle model

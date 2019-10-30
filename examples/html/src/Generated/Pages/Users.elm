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


page : Application.Page Route Model Msg (Html Msg) a b (Html b) Global.Model Global.Msg c (Html c)
page =
    Application.layout
        { map = Html.map
        , layout = Layout.view
        , pages =
            { init = init
            , update = update
            , bundle = bundle
            }
        }


slug : Application.Recipe Route.SlugParams Slug.Model Slug.Msg Model Msg (Html Msg) Global.Model Global.Msg a (Html a)
slug =
    Slug.page
        { toModel = SlugModel
        , toMsg = SlugMsg
        , map = Html.map
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


bundle : Model -> Application.Bundle Msg (Html Msg) Global.Model Global.Msg msg (Html msg)
bundle model_ =
    case model_ of
        SlugModel model ->
            slug.bundle model

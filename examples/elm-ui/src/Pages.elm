module Pages exposing
    ( Model
    , Msg
    , bundle
    , init
    , update
    )

import Application
import Application.Page
import Element exposing (Element)
import Flags exposing (Flags)
import Global
import Pages.Homepage
import Pages.NotFound
import Route exposing (Route)


type Model
    = HomepageModel ()
    | NotFoundModel ()


type Msg
    = HomepageMsg Never
    | NotFoundMsg Never


pages =
    { homepage =
        Application.Page.static
            { title = "examples/elm-ui"
            , view = Pages.Homepage.view
            , toModel = HomepageModel
            , fromNever = Element.map never
            }
    , notFound =
        Application.Page.static
            { title = "Page not found"
            , view = Pages.NotFound.view
            , toModel = NotFoundModel
            , fromNever = Element.map never
            }
    }


app =
    { bundle = Application.bundle Element.map
    }


init :
    Route
    -> Application.Update Flags Route Global.Model Global.Msg Model Msg
init route =
    case route of
        Route.Homepage ->
            Application.init
                { page = pages.homepage
                }

        Route.NotFound ->
            Application.init
                { page = pages.notFound
                }


update :
    Msg
    -> Model
    -> Application.Update Flags Route Global.Model Global.Msg Model Msg
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
    -> Application.Bundle Flags Route Global.Model Msg (Element Msg)
bundle appModel =
    case appModel of
        HomepageModel model ->
            app.bundle
                { page = pages.homepage
                , model = model
                }

        NotFoundModel model ->
            app.bundle
                { page = pages.notFound
                , model = model
                }

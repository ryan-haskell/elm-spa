import {
  pagesImports, paramsImports,
  pagesBundleAnnotation,
  pagesBundleDefinition,
  pagesInitBody,
  pagesSubscriptionsBody,
  pagesViewBody,
  pagesUpdateBody,
  pagesUpdateCatchAll,
  Options
} from "./utils"

export default (pages : string[][], options : Options) : string => `
module Gen.Pages exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import ElmSpa.Internals.Page
${paramsImports(pages)}
import Gen.Model as Model
import Gen.Msg as Msg
import Gen.Route as Route exposing (Route)
import Page exposing (Page)
${pagesImports(pages)}
import Request exposing (Request)
import Shared
import Task
import Url exposing (Url)
import View exposing (View)


type alias Model =
    Model.Model


type alias Msg =
    Msg.Msg


init : Route -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
init route =
${pagesInitBody(pages)}


update : Msg -> Model -> Shared.Model -> Url -> Key -> ( Model, Effect Msg )
update msg_ model_ =
${pagesUpdateBody(pages.filter(page => options.isStatic(page) === false), options)}
${pages.length > 1 ? pagesUpdateCatchAll : ''}


view : Model -> Shared.Model -> Url -> Key -> View Msg
view model_ =
${pagesViewBody(pages, options)}


subscriptions : Model -> Shared.Model -> Url -> Key -> Sub Msg
subscriptions model_ =
${pagesSubscriptionsBody(pages, options)}



-- INTERNALS


pages :
${pagesBundleAnnotation(pages, options)}
pages =
${pagesBundleDefinition(pages, options)}


type alias Bundle params model msg =
    ElmSpa.Internals.Page.Bundle params model msg Shared.Model (Effect Msg) Model Msg (View Msg)


bundle page toModel toMsg =
    ElmSpa.Internals.Page.bundle
        { redirecting =
            { model = Model.Redirecting_
            , view = View.none
            }
        , toRoute = Route.fromUrl
        , toUrl = Route.toHref
        , fromCmd = Effect.fromCmd
        , mapEffect = Effect.map toMsg
        , mapView = View.map toMsg
        , toModel = toModel
        , toMsg = toMsg
        , page = page
        }


type alias Static params =
    Bundle params () Never


static : View Never -> (params -> Model) -> Static params
static view_ toModel =
    { init = \\params _ _ _ -> ( toModel params, Effect.none )
    , update = \\params _ _ _ _ _ -> ( toModel params, Effect.none )
    , view = \\_ _ _ _ _ -> View.map never view_
    , subscriptions = \\_ _ _ _ _ -> Sub.none
    }
    
`.trimLeft()

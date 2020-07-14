module Pages.Top exposing (Model, Msg, Params, page)

import Api.Data
import Browser.Navigation as Nav
import Shared
import Html exposing (..)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)


type alias Params =
    ()


type alias Model =
    {}


type Msg
    = ReplaceMe


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared _ =
    case Api.Data.toMaybe shared.user of
        Just _ ->
            ( {}, Nav.pushUrl shared.key (Route.toString Route.Projects) )

        Nothing ->
            ( {}, Nav.pushUrl shared.key (Route.toString Route.SignIn) )


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Document Msg
view model =
    { title = "Top"
    , body = []
    }

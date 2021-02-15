module Pages.Dashboard exposing (Model, Msg, page)

import Gen.Params.Dashboard exposing (Params)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import View exposing (View)


type alias User =
    ()


page : Shared.Model -> Request Params -> Page Model Msg
page shared req =
    Page.protected.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    {}


init : User -> Model
init user =
    {}



-- UPDATE


type Msg
    = ReplaceMe


update : User -> Msg -> Model -> Model
update user msg model =
    case msg of
        ReplaceMe ->
            model



-- VIEW


view : User -> Model -> View Msg
view user model =
    View.placeholder "Dashboard"

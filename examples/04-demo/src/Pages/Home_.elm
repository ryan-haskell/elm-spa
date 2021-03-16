module Pages.Home_ exposing (Model, Msg, page, view)

import Auth
import Effect exposing (Effect)
import Html
import Html.Events as Events
import Page
import Request exposing (Request)
import Shared
import UI
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.advanced <|
        \user ->
            { init = init
            , update = update
            , view = view user
            , subscriptions = \_ -> Sub.none
            }



-- INIT


type alias Model =
    {}


init : ( Model, Effect Msg )
init =
    ( {}, Effect.none )



-- UPDATE


type Msg
    = ClickedSignOut


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickedSignOut ->
            ( model
            , Effect.fromShared Shared.SignedOut
            )


view : Auth.User -> Model -> View Msg
view user _ =
    { title = "Homepage"
    , body =
        UI.layout
            [ Html.h1 [] [ Html.text ("Hello, " ++ user.name ++ "!") ]
            , Html.button [ Events.onClick ClickedSignOut ] [ Html.text "Sign out" ]
            ]
    }

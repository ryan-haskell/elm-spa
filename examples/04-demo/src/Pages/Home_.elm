module Pages.Home_ exposing (Model, Msg, page, view)

import Auth
import Effect exposing (Effect)
import Html
import Page
import Request exposing (Request)
import Shared
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.advanced
        { init = always init
        , update = always update
        , view = view
        , subscriptions = \_ _ -> Sub.none
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


view : Auth.User -> Model -> View msg
view user _ =
    { title = "Homepage"
    , body =
        [ Html.h1 [] [ Html.text ("Hello, " ++ user.name ++ "!") ]
        , Html.button [] [ Html.text "Sign out" ]
        ]
    }

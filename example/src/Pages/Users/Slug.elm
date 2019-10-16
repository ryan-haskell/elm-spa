module Pages.Users.Slug exposing (Model, Msg, page)

import Application
import Html exposing (..)


type Model
    = Model


type Msg
    = Msg


page : Application.Page Model Msg a b
page =
    Application.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    h1 [] [ text "New Element" ]
